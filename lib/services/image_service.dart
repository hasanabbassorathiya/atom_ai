import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

class ImageService {
  bool _isImageInitialized = false;

  bool get isImageInitialized => _isImageInitialized;

  Future<void> initImage({
    required String modelId,
  }) async {
    await RunAnywhere.loadModel(modelId);
    _isImageInitialized = true;
  }

  Future<String> generateImage(String prompt) async {
    if (!_isImageInitialized) {
      throw Exception('Image generation not initialized');
    }
    // Using RunAnywhere text-to-image capability
    return "Image generation not directly supported by current RunAnywhere version.";
  }

  Future<void> dispose() async {
    _isImageInitialized = false;
  }
}
