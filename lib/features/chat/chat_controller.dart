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

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  final RunAnywhereService runAnywhereService;

  ChatController(this.ref, this.runAnywhereService) : super(ChatState());

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);

    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

    final stream = await runAnywhereService.chatStream(text);

    await for (final token in stream) {
      final newMessages = List<Map<String, String>>.from(state.messages);
      newMessages.last['content'] = (newMessages.last['content'] ?? '') + token;
      state = state.copyWith(messages: newMessages);
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      runAnywhereService.stopVoiceSession();
      state = state.copyWith(isRecording: false);
    } else {
      state = state.copyWith(isRecording: true);
      await runAnywhereService.startVoiceSession((transcript, response) {
        state = state.copyWith(
          messages: [...state.messages, {'role': 'user', 'content': transcript}, {'role': 'assistant', 'content': response}],
          isRecording: false,
        );
      });
    }
  }

  Future<void> sendImage(String imagePath) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': 'Image attached'}]);

    // Call RunAnywhere vision processing
    await runAnywhereService.processVision(imagePath, "Describe this image");

    state = state.copyWith(isLoading: false);
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref, ref.watch(runAnywhereServiceProvider));
});
