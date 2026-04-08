import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/conversation.dart';
import 'chat_controller.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input.dart';

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
    final chatState = ref.watch(chatControllerProvider);
    final chatNotifier = ref.read(chatControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Atom AI'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];
                return ChatBubble(
                  message: Message.assistant('convId', msg['content'] ?? ''),
                  isDark: true,
                ).animate().fadeIn(duration: 300.ms).moveY(begin: 10, end: 0);
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
