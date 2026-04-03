import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/ai_interfaces.dart';
import 'voice_service_impl.dart';

final voiceServiceProvider = NotifierProvider<VoiceNotifier, VoiceServiceImpl>(VoiceNotifier.new);

class VoiceNotifier extends Notifier<VoiceServiceImpl> {
  @override
  VoiceServiceImpl build() => VoiceServiceImpl();

  Future<void> start() async {
    await state.startVoiceSession((transcript, response) {});
  }

  Future<void> stop() async {
    state.stopVoiceSession();
  }
}
