import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../services/document_service.dart';
import '../../services/active_models_service.dart';
import '../../core/widgets/model_selector_dropdown.dart';
import '../../data/models/conversation.dart';
import '../chat/widgets/chat_bubble.dart';
import '../chat/widgets/chat_input.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final List<String> _documents = [];
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isIndexing = false;
  bool _isStreaming = false;
  String _streamingText = '';
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final activeModels = ref.read(activeModelsProvider);
    if (activeModels.chatModel == null || activeModels.embeddingModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a Chat and an Embedding model first')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt'],
    );
    if (result == null) return;

    setState(() => _isIndexing = true);
    try {
      final file = result.files.single;
      final text = await _extractText(file);
      final docService = ref.read(documentServiceProvider);
      await docService.addDocument(
        file.name,
        text,
        chatModelId: activeModels.chatModel!.id,
        embedderModelId: activeModels.embeddingModel!.id,
      );
      setState(() => _documents.add(file.name));

      if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${file.name} to knowledge base')),
      );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process document: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isIndexing = false);
    }
  }

  Future<String> _extractText(PlatformFile file) async {
    if (file.path == null) throw Exception('File path is null');

    if (file.extension == 'pdf') {
      final fileData = await File(file.path!).readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: fileData);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    }
    return await File(file.path!).readAsString();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a document first')),
      );
      return;
    }

    final userMsg = Message.user('doc_session', text);
    setState(() {
      _messages.add(userMsg);
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    try {
      final docService = ref.read(documentServiceProvider);
      await for (final chunk in docService.queryStream(text)) {
        if (!mounted) break;
        if (!chunk.isFinal) {
          setState(() {
            _streamingText += chunk.token;
          });
          _scrollToBottom();
        }
      }
      
      if (mounted && _streamingText.isNotEmpty) {
        setState(() {
          _messages.add(Message.assistant('doc_session', _streamingText));
          _streamingText = '';
          _isStreaming = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(Message.assistant('doc_session', 'Error: $e'));
          _streamingText = '';
          _isStreaming = false;
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Q&A'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.embedding),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.chat),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _isIndexing ? null : _pickDocument,
            tooltip: 'Add Document',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_documents.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _documents.length,
                separatorBuilder: (context, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => Chip(
                  label: Text(_documents[i], style: const TextStyle(fontSize: 12)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          if (_isIndexing) const LinearProgressIndicator(),
          
          Expanded(
            child: _documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No Documents', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Add a PDF or Text file to start asking questions.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _pickDocument,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Document'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isStreaming ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return ChatBubble(
                          message: _messages[index],
                          isDark: isDark,
                        );
                      }
                      return ChatBubble(
                        message: Message.assistant('doc_session', _streamingText),
                        isDark: isDark,
                        isStreaming: true,
                      );
                    },
                  ),
          ),
          
          ChatInput(
            onSend: _sendMessage,
            isEnabled: _documents.isNotEmpty && !_isStreaming && !_isIndexing,
            isStreaming: _isStreaming,
            onCancel: () {}, // Basic cancel support
          ),
        ],
      ),
    );
  }
}
