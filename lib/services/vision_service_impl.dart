import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';
import '../domain/services/ai_interfaces.dart';

class VisionServiceImpl implements VisionService {
  @override
  bool get isVisionInitialized => false;
  
  @override
  bool get isImageInitialized => false;

  @override
  String? get currentModelId => null;

  @override
  Future<void> initVision({required String modelId, String? modelPath, String? mmprojPath}) async {}
  
  @override
  Future<void> initImage({required String modelId, String? modelPath}) async {}
  
  @override
  Future<String> describeImage(Uint8List rgbBytes, {required int width, required int height}) async {
    return "Vision is temporarily unavailable.";
  }
  
  @override
  Future<Uint8List> generateImage(String prompt, {required ImageGenerationConfig config, Function(ImageProgress)? onProgress}) async {
    return Uint8List(0);
  }
}
