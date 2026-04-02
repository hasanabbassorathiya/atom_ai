import 'package:edge_veda/edge_veda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/active_models_service.dart';
import '../../services/model_service.dart';

enum ModelCategoryType { chat, vision, stt, image, embedding }

class ModelSelectorDropdown extends ConsumerStatefulWidget {
  final ModelCategoryType categoryType;

  const ModelSelectorDropdown({
    super.key,
    required this.categoryType,
  });

  @override
  ConsumerState<ModelSelectorDropdown> createState() => _ModelSelectorDropdownState();
}

class _ModelSelectorDropdownState extends ConsumerState<ModelSelectorDropdown> {
  List<ModelInfo> _downloadedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDownloadedModels();
  }

  Future<void> _loadDownloadedModels() async {
    final modelService = ref.read(modelServiceProvider);
    final categoryIcon = _getCategoryIcon(widget.categoryType);
    
    try {
      final category = modelService.getModelCategories().firstWhere((c) => c.icon == categoryIcon);
      final downloaded = <ModelInfo>[];
      
      for (final model in category.models) {
        if (await modelService.isDownloaded(model.id)) {
          downloaded.add(model);
        }
      }
      
      if (mounted) {
        setState(() {
          _downloadedModels = downloaded;
          _isLoading = false;
        });
        
        // Auto-select if nothing is selected but we have downloaded models
        if (downloaded.isNotEmpty) {
          final activeState = ref.read(activeModelsProvider);
          if (_getCurrentModel(activeState) == null) {
            _onModelSelected(downloaded.first);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getCategoryIcon(ModelCategoryType type) {
    return switch (type) {
      ModelCategoryType.chat => 'chat',
      ModelCategoryType.vision => 'visibility',
      ModelCategoryType.stt => 'mic',
      ModelCategoryType.image => 'image',
      ModelCategoryType.embedding => 'hub',
    };
  }

  ModelInfo? _getCurrentModel(ActiveModelsState state) {
    return switch (widget.categoryType) {
      ModelCategoryType.chat => state.chatModel,
      ModelCategoryType.vision => state.visionModel,
      ModelCategoryType.stt => state.sttModel,
      ModelCategoryType.image => state.imageModel,
      ModelCategoryType.embedding => state.embeddingModel,
    };
  }

  void _onModelSelected(ModelInfo? model) {
    if (model == null) return;
    
    final notifier = ref.read(activeModelsProvider.notifier);
    switch (widget.categoryType) {
      case ModelCategoryType.chat:
        notifier.setChatModel(model);
        break;
      case ModelCategoryType.vision:
        notifier.setVisionModel(model);
        break;
      case ModelCategoryType.stt:
        notifier.setSttModel(model);
        break;
      case ModelCategoryType.image:
        notifier.setImageModel(model);
        break;
      case ModelCategoryType.embedding:
        notifier.setEmbeddingModel(model);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeModels = ref.watch(activeModelsProvider);
    final currentModel = _getCurrentModel(activeModels);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_downloadedModels.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Text(
            'No models',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      );
    }

    // Default to the first one if the currentModel is null or not found in downloaded
    ModelInfo? selectedModel = currentModel;
    if (selectedModel == null || !_downloadedModels.any((m) => m.id == selectedModel!.id)) {
      selectedModel = _downloadedModels.first;
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<ModelInfo>(
        value: selectedModel,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        alignment: Alignment.centerRight,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
        items: _downloadedModels.map((model) {
          return DropdownMenuItem(
            value: model,
            child: Text(
              model.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: _onModelSelected,
      ),
    );
  }
}
