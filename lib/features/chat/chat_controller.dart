import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/ai_interfaces.dart';
import '../../services/chat_service_impl.dart';
import '../../services/voice_service.dart';
import '../../services/vision_service.dart';

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

  ChatService get _chatService => ChatServiceImpl(); // Should use a provider

  Future<void> sendMessage(String text) async {
    state = state.copyWith(isLoading: true, messages: [...state.messages, {'role': 'user', 'content': text}]);
    state = state.copyWith(messages: [...state.messages, {'role': 'assistant', 'content': ''}]);

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
}

final chatControllerProvider = NotifierProvider<ChatController, ChatState>(ChatController.new);
