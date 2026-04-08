import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() => ChatState();

  EdgeVedaService get _edgeVedaService => ref.read(edgeVedaServiceProvider);

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);
    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

    final session = _edgeVedaService.chatSession;
    if (session == null) {
      state = state.copyWith(isLoading: false, status: "Session not initialized");
      return;
    }

    await for (final chunk in session.sendStream(text)) {
      if (!chunk.isFinal) {
        final newMessages = List<Map<String, String>>.from(state.messages);
        newMessages.last['content'] = (newMessages.last['content'] ?? '') + chunk.token;
        state = state.copyWith(messages: newMessages);
      }
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> toggleRecording() async {
    // Recording logic currently stubbed
  }

  Future<void> sendImage(String imagePath) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': 'Analyzing image...'}]);
    state = state.copyWith(isLoading: false, status: 'Vision temporarily unavailable');
  }
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
