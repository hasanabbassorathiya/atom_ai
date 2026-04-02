import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isEnabled;
  final bool isStreaming;
  final VoidCallback onToggleRecording;
  final VoidCallback onAttachPressed;
  final bool isRecording;
  final VoidCallback? onCancel;

  const ChatInput({
    super.key,
    required this.onSend,
    this.isEnabled = true,
    this.isStreaming = false,
    this.onCancel,
    required this.onToggleRecording,
    required this.onAttachPressed,
    this.isRecording = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  widget.isRecording ? Icons.mic_off : Icons.mic,
                  color: widget.isRecording ? AppColors.error : AppColors.primary,
                ),
                onPressed: widget.onToggleRecording,
              ),
              IconButton(
                icon: const Icon(Icons.attach_file, color: AppColors.onSurfaceVariantDark),
                onPressed: widget.onAttachPressed,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.isEnabled,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.isEnabled
                          ? 'Ask anything...'
                          : 'Loading model...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: widget.isEnabled ? (_) => _send() : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              widget.isStreaming
                  ? IconButton.filled(
                      icon: const Icon(Icons.stop),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: widget.onCancel,
                    )
                  : IconButton.filled(
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: widget.isEnabled ? _send : null,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
