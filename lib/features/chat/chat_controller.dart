import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edge_veda/edge_veda.dart';
import '../../services/edge_veda_service.dart';

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
  final EdgeVedaService edgeVedaService;

  ChatController(this.ref, this.edgeVedaService) : super(ChatState());

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);

    final session = edgeVedaService.chatSession;
    if (session == null) return;

    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

    await for (final chunk in session.sendStream(text)) {
      if (!chunk.isFinal) {
        final newMessages = List<Map<String, String>>.from(state.messages);
        newMessages.last['content'] = (newMessages.last['content'] ?? '') + chunk.token;
        state = state.copyWith(messages: newMessages);
      }
    }
    state = state.copyWith(isLoading: false);
  }

  // Voice/Vision methods to be implemented
}

final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController(ref, ref.watch(edgeVedaServiceProvider));
});
