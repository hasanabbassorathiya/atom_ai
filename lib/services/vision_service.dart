import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_runtime_service.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  final runtime = ref.watch(aiRuntimeProvider.notifier);
  return VisionService(runtime: runtime);
});

class VisionService {
  final AiRuntimeNotifier _runtime;
  bool _isVisionInitialized = false;
  String? currentModelId;

  VisionService({required AiRuntimeNotifier runtime})
      : _runtime = runtime;

  bool get isVisionInitialized => _isVisionInitialized;

  Future<void> initVision({
    required String modelId,
    required String modelPath,
    String? mmprojPath,
  }) async {
    if (_isVisionInitialized && currentModelId == modelId) return;

    await _runtime.engine.initVision(VisionConfig(
      modelPath: modelPath,
      mmprojPath: mmprojPath ?? '',
    ));
    currentModelId = modelId;
    _isVisionInitialized = true;
  }

  Future<String> describeImage(
    Uint8List imageBytes, {
    required int width,
    required int height,
    String prompt = 'Describe this image.',
  }) async {
    if (!_isVisionInitialized) {
      throw const VisionException('Vision not initialized');
    }
    return await _runtime.engine.describeImage(
      imageBytes,
      width: width,
      height: height,
      prompt: prompt,
    );
  }

  Future<void> dispose() async {
    await _runtime.engine.disposeVision();
    _isVisionInitialized = false;
    currentModelId = null;
  }
}
