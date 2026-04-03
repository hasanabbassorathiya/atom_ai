import '../domain/services/ai_interfaces.dart';

class VoiceServiceImpl implements VoiceService {
  @override
  bool get isRunning => false;
  @override
  String get transcript => "";
  
  @override
  Future<void> startVoiceSession(Function(String, String) onTurnCompleted) async {}
  
  @override
  void stopVoiceSession() {}
}
