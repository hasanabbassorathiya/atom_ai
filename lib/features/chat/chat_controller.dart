import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import '../../domain/services/ai_interfaces.dart';
import '../../services/chat_service_impl.dart';
import '../../services/voice_service.dart';
import '../../services/vision_service.dart';
=======
import '../../services/edge_veda_service.dart';
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)

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

<<<<<<< HEAD
  ChatService get _chatService => ChatServiceImpl(); // Should use a provider
=======
  EdgeVedaService get _edgeVedaService => ref.read(edgeVedaServiceProvider);
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);
    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

<<<<<<< HEAD
    final stream = await _chatService.chatStream(text);

    await for (final token in stream) {
      final newMessages = List<Map<String, String>>.from(state.messages);
      newMessages.last['content'] = (newMessages.last['content'] ?? '') + token;
      state = state.copyWith(messages: newMessages);
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
=======
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
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
