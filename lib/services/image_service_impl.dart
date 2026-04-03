import '../domain/services/ai_interfaces.dart';

class VisionServiceImpl implements VisionService {
  @override
  bool get isVisionInitialized => false;
  
  @override
  Future<void> initVision({required String modelId}) async {}
  
  @override
  Future<void> initImage({required String modelId}) async {}
  
  @override
  Future<String> describeImage(String imagePath, {String prompt = 'Describe this image.'}) async {
    return "Vision is temporarily unavailable.";
  }
  
  @override
  Future<String> generateImage(String prompt) async {
    return "Image generation unavailable.";
  }
}
