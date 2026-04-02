import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/runanywhere_service.dart';

class ChatState {
  final List<Map<String, String>> messages;
  final bool isLoading;
  final bool isRecording;
  final String? status;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isRecording = false,
    this.status,
  });

  ChatState copyWith({
    List<Map<String, String>>? messages,
    bool? isLoading,
    bool? isRecording,
    String? status,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isRecording: isRecording ?? this.isRecording,
      status: status ?? this.status,
    );
  }
}

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState();
  }

  RunAnywhereService get _runAnywhereService => ref.read(runAnywhereServiceProvider);

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);

    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

    final stream = await _runAnywhereService.chatStream(text);

    await for (final token in stream) {
      final newMessages = List<Map<String, String>>.from(state.messages);
      newMessages.last['content'] = (newMessages.last['content'] ?? '') + token;
      state = state.copyWith(messages: newMessages);
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      _runAnywhereService.stopVoiceSession();
      state = state.copyWith(isRecording: false, status: null);
    } else {
      state = state.copyWith(isRecording: true, status: 'Listening...');
      await _runAnywhereService.startVoiceSession((transcript, response) {
        state = state.copyWith(
          messages: [
            ...state.messages,
            {'role': 'user', 'content': transcript},
            {'role': 'assistant', 'content': response}
          ],
          isRecording: false,
          status: null,
        );
      });
    }
  }

  Future<void> sendImage(String imagePath) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': 'Analyzing image...'}]);

    try {
      await _runAnywhereService.processVision(imagePath, "Describe this image");
      state = state.copyWith(isLoading: false, status: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, status: 'Vision error: $e');
    }
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
