import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final voiceServiceProvider = NotifierProvider<VoiceNotifier, VoiceState>(VoiceNotifier.new);

class VoiceState {
  final bool isRunning;
  final String transcript;

  VoiceState({
    this.transcript = '',
    this.isRunning = false,
  });

  VoiceState copyWith({
    String? transcript,
    bool? isRunning,
  }) {
    return VoiceState(
      transcript: transcript ?? this.transcript,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class VoiceNotifier extends Notifier<VoiceState> {
  VoiceSessionHandle? _session;

  @override
  VoiceState build() => VoiceState();

  Future<void> start() async {
    _session = await RunAnywhere.startVoiceSession();
    state = state.copyWith(isRunning: true);

    _session!.events.listen((event) {
      if (event is VoiceSessionTurnCompleted) {
        state = state.copyWith(transcript: event.transcript);
      }
    });
  }

  Future<void> stop() async {
    _session?.stop();
    _session = null;
    state = VoiceState();
  }
}
