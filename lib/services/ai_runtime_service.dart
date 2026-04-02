import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

// Use NotifierProvider instead of ChangeNotifierProvider for Riverpod 3
final aiRuntimeProvider =
    NotifierProvider<AiRuntimeNotifier, AiRuntimeState>(AiRuntimeNotifier.new);

class AiRuntimeState {
  final bool isInitialized;
  final bool isGenerating;
  final String? currentModelId;

  AiRuntimeState({
    this.isInitialized = false,
    this.isGenerating = false,
    this.currentModelId,
  });

  AiRuntimeState copyWith({
    bool? isInitialized,
    bool? isGenerating,
    String? currentModelId,
  }) {
    return AiRuntimeState(
      isInitialized: isInitialized ?? this.isInitialized,
      isGenerating: isGenerating ?? this.isGenerating,
      currentModelId: currentModelId ?? this.currentModelId,
    );
  }
}

class AiRuntimeNotifier extends Notifier<AiRuntimeState> {
  @override
  AiRuntimeState build() => AiRuntimeState();

  Future<void> initWithModel({
    required String modelId,
  }) async {
    debugPrint('[AiRuntime] Initializing model with ID: $modelId');

    try {
      await RunAnywhere.loadModel(modelId);
      state = state.copyWith(
        isInitialized: true,
        currentModelId: modelId,
      );
    } catch (e, stack) {
      debugPrint('[AiRuntime] CRITICAL ERROR: RunAnywhere.loadModel failed: $e\n$stack');
      rethrow;
    }
  }

  Stream<String> sendMessage(String text) async* {
    if (!state.isInitialized) {
      throw Exception('AI runtime not initialized');
    }
    if (state.isGenerating) {
      throw Exception('Generation already in progress');
    }

    state = state.copyWith(isGenerating: true);

    try {
      final streamResult = await RunAnywhere.generateStream(text);
      await for (final token in streamResult.stream) {
        yield token;
      }
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  bool get isInitialized => state.isInitialized;
  String? get currentModelId => state.currentModelId;
}
