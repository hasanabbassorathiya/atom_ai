import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/model_selector_dropdown.dart';
import '../../services/image_service.dart';
import 'package:atom_ai/domain/models/atom_model_config.dart';
import '../../services/active_models_service.dart';

class ImageGenScreen extends ConsumerStatefulWidget {
  const ImageGenScreen({super.key});

  @override
  ConsumerState<ImageGenScreen> createState() => _ImageGenScreenState();
}

class _ImageGenScreenState extends ConsumerState<ImageGenScreen> {
  final _controller = TextEditingController();
  bool _isGenerating = false;
  String _generatedImagePath = '';
  String _currentPrompt = '';

  Future<void> _generate() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _currentPrompt = prompt;
      _isGenerating = true;
      _generatedImagePath = '';
    });

    try {
      final imageService = ref.read(imageServiceProvider);
      final activeModels = ref.read(activeModelsProvider);

      if (activeModels.imageModel == null) {
        throw Exception('Please select an Image Generation model first');
      }

      if (!imageService.isVisionInitialized) {
        await imageService.initVision(modelId: activeModels.imageModel!.id);
      }

      final path = await imageService.generateImage(prompt);

      if (mounted) {
        setState(() => _generatedImagePath = path);
      }
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
            child: Center(
              child: _generatedImagePath.isNotEmpty
                ? Image.network(_generatedImagePath) 
                : _isGenerating
                  ? const CircularProgressIndicator()
                  : const Text('Enter a prompt to generate an image'),
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Describe an image...'),
                  ),
                ),
                IconButton(
                  onPressed: _isGenerating ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
