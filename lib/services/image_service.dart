import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_runtime_service.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  final runtime = ref.watch(aiRuntimeProvider.notifier);
  return ImageService(runtime: runtime);
});

class ImageService {
  final AiRuntimeNotifier _runtime;
  bool _isImageInitialized = false;
  String? currentModelId;

  ImageService({required AiRuntimeNotifier runtime})
      : _runtime = runtime;

  bool get isImageInitialized => _isImageInitialized;

  Future<void> initImage({
    required String modelId,
    required String modelPath,
  }) async {
    if (_isImageInitialized && currentModelId == modelId) return;

    await _runtime.engine.initImageGeneration(modelPath: modelPath);
    currentModelId = modelId;
    _isImageInitialized = true;
  }

  Future<Uint8List> generateImage(
    String prompt, {
    ImageGenerationConfig? config,
    void Function(ImageProgress)? onProgress,
  }) async {
    if (!_isImageInitialized) {
      throw const ImageGenerationException('Image generation not initialized');
    }
    return await _runtime.engine.generateImage(
      prompt,
      config: config,
      onProgress: onProgress,
    );
  }

  Future<void> dispose() async {
    await _runtime.engine.disposeImageGeneration();
    _isImageInitialized = false;
  }
}
