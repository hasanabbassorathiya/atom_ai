import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';
import '../../data/models/conversation.dart'; // Ensure correct path

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref.read(chatControllerProvider.notifier).sendImage(image.path);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatControllerProvider);
    final chatNotifier = ref.read(chatControllerProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Atom AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return ChatBubble(
                  message: Message.assistant('convId', msg['content'] ?? ''),
                  isDark: isDark,
                );
              },
            ),
          ),
          ChatInput(
            onSend: (text) {
              chatNotifier.sendMessage(text);
              _scrollToBottom();
            },
            onToggleRecording: () => chatNotifier.toggleRecording(),
            onAttachPressed: _pickImage,
            isRecording: chatState.isRecording,
            isEnabled: !chatState.isLoading,
            isStreaming: chatState.isLoading,
            onCancel: () {},
          ),
        ],
      ),
    );
  }
}
