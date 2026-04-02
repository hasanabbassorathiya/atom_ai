import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final visionServiceProvider = Provider<VisionService>((ref) {
  return VisionService();
});

class VisionService {
  bool _isVisionInitialized = false;

  bool get isVisionInitialized => _isVisionInitialized;

  Future<void> initVision({
    required String modelId,
  }) async {
    await RunAnywhere.loadModel(modelId); // Assuming vision model loaded here
    _isVisionInitialized = true;
  }

  Future<String> describeImage(
    String imagePath, {
    String prompt = 'Describe this image.',
  }) async {
    if (!_isVisionInitialized) {
      throw Exception('Vision not initialized');
    }
    // RunAnywhere SDK does not provide direct generateVision.
    // Assuming vision processing is handled through generic chat interface
    // or not directly supported.
    return "Vision processing not directly supported by current RunAnywhere version.";
  }

  Future<void> dispose() async {
    _isVisionInitialized = false;
  }
}
