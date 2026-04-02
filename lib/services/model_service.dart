import 'dart:async';
import 'dart:io';

import 'package:edge_veda/edge_veda.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final modelServiceProvider = Provider<ModelService>((ref) => ModelService());

class ModelDownloadProgress {
  final String modelId;
  final double progress;

  ModelDownloadProgress({required this.modelId, required this.progress});
}

class ModelService {
  final ModelManager _manager = ModelManager();
  String? _currentDownloadingModelId;
  final _progressController = StreamController<ModelDownloadProgress>.broadcast();

  ModelService() {
    _manager.downloadProgress.listen((progress) {
      if (_currentDownloadingModelId != null) {
        _progressController.add(ModelDownloadProgress(
          modelId: _currentDownloadingModelId!,
          progress: progress.progress,
        ));
      }
    });
  }

  ModelManager get manager => _manager;

  Stream<ModelDownloadProgress> get downloadProgress => _progressController.stream;

  Future<String> ensureModel(ModelInfo model) {
    _currentDownloadingModelId = model.id;
    return _manager.downloadModel(model);
  }

  Future<bool> isDownloaded(String modelId) =>
      _manager.isModelDownloaded(modelId);

  Future<String> getModelPath(String modelId) async {
    final path = await _manager.getModelPath(modelId);
    debugPrint('[ModelService] Path for $modelId: $path');
    return path;
  }

  Future<int?> getModelSize(String modelId) => _manager.getModelSize(modelId);

  void cancelDownload() => _manager.cancelDownload();

  Future<void> deleteModel(String modelId) async {
    final path = await _manager.getModelPath(modelId);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  List<ModelCategory> getModelCategories() {
    return [
      ModelCategory(
        name: 'Chat Models',
        icon: 'chat',
        models: [
          ModelRegistry.llama32_1b,
          ModelRegistry.gemma2_2b,
          ModelRegistry.phi35_mini,
          ModelRegistry.qwen3_06b,
          ModelRegistry.tinyLlama,
          ModelRegistry.llama31_8b,
          ModelRegistry.mistral_nemo_12b,
        ],
      ),
      ModelCategory(
        name: 'Vision Models',
        icon: 'visibility',
        models: [
          ModelRegistry.smolvlm2_500m,
          ModelRegistry.smolvlm2_256m,
          ModelRegistry.llava16_mistral_7b,
          ModelRegistry.qwen2vl_7b,
        ],
      ),
      ModelCategory(
        name: 'Speech-to-Text',
        icon: 'mic',
        models: [
          ModelRegistry.whisperTinyEn,
          ModelRegistry.whisperBaseEn,
          ModelRegistry.whisperSmall,
          ModelRegistry.whisperMedium,
          ModelRegistry.whisperLargeV3,
        ],
      ),
      ModelCategory(
        name: 'Image Generation',
        icon: 'image',
        models: [
          ModelRegistry.sdV21Turbo,
          ModelRegistry.sdxlTurbo,
          ModelRegistry.flux1Schnell,
        ],
      ),
      ModelCategory(
        name: 'Embeddings',
        icon: 'hub',
        models: [
          ModelRegistry.allMiniLmL6V2,
          ModelRegistry.nomicEmbedText,
          ModelRegistry.mxbaiEmbedLarge,
        ],
      ),
    ];
  }

  void dispose() => _manager.dispose();
}

class ModelCategory {
  final String name;
  final String icon;
  final List<ModelInfo> models;
  const ModelCategory({
    required this.name,
    required this.icon,
    required this.models,
  });
}
