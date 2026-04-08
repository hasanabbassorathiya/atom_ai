import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/model_selector_dropdown.dart';
import '../../services/active_models_service.dart';
import '../../services/image_service.dart';
import '../../services/model_service.dart';
import 'package:edge_veda/edge_veda.dart';

class ImageGenScreen extends ConsumerStatefulWidget {
  const ImageGenScreen({super.key});

  @override
  ConsumerState<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends ConsumerState<ImageGenScreen> {
  final _controller = TextEditingController();
  bool _isGenerating = false;
  double _progress = 0;
  Uint8List? _imageData;
  String _currentPrompt = '';

  Future<void> _generate() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _currentPrompt = prompt;
      _isGenerating = true;
      _imageData = null;
      _progress = 0;
    });

    try {
      final imageService = ref.read(imageServiceProvider);
      final activeModels = ref.read(activeModelsProvider);

      if (activeModels.imageModel == null) {
        throw Exception('Please select an Image Generation model first');
      }

      if (!imageService.isImageInitialized || imageService.currentModelId != activeModels.imageModel!.id) {
        final modelPath = await ref.read(modelServiceProvider).getModelPath(activeModels.imageModel!.id);
        await imageService.initImage(modelId: activeModels.imageModel!.id, modelPath: modelPath);
      }

      final bytes = await imageService.generateImage(
        prompt,
        config: const ImageGenerationConfig(steps: 4),
        onProgress: (p) => setState(() => _progress = p.progress),
      );
      if (mounted) setState(() => _imageData = bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.image),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_imageData != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          if (isDark)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 32,
                              spreadRadius: 8,
                            )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(_imageData!, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _currentPrompt,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () => SharePlus.instance.share(
                            ShareParams(
                              files: [
                                XFile.fromData(_imageData!, mimeType: 'image/png', name: 'generation.png')
                              ],
                              text: _currentPrompt,
                            ),
                          ),
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ],
                    ),
                  ] else if (_isGenerating) ...[
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: _progress > 0 ? _progress : null,
                                    strokeWidth: 4,
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  ),
                                ),
                                Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Dreaming...',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_progress * 100).toInt()}% complete',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ] else ...[
                    SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_search_outlined,
                              size: 80,
                              color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Create anything',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a prompt to generate an image offline',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16).copyWith(bottom: 16 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF000000) : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _generate(),
                      decoration: InputDecoration(
                        hintText: 'Describe an image to generate...',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: InputBorder.none,
                        enabled: !_isGenerating,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _isGenerating || _controller.text.isEmpty ? null : _generate,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.auto_awesome, color: Colors.black87),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
