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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
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
                          : 'Loading...',
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onSubmitted: widget.isEnabled ? (_) => _send() : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                icon: Icon(widget.isStreaming ? Icons.stop : Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                ),
                onPressed: widget.isEnabled
                    ? (widget.isStreaming ? widget.onCancel : _send)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
