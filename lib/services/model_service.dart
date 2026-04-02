import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final modelServiceProvider = Provider<ModelService>((ref) => ModelService());

class ModelDownloadProgress {
  final String modelId;
  final double progress;

  ModelDownloadProgress({required this.modelId, required this.progress});
}

class ModelService {
  final _progressController = StreamController<ModelDownloadProgress>.broadcast();

  Stream<ModelDownloadProgress> get downloadProgress => _progressController.stream;

  Future<void> ensureModel(String modelId) async {
    await for (final p in RunAnywhere.downloadModel(modelId)) {
      _progressController.add(ModelDownloadProgress(modelId: modelId, progress: p.percentage));
    }
  }

  Future<bool> isDownloaded(String modelId) async {
    final models = await RunAnywhere.availableModels();
    return models.any((m) => m.id == modelId && m.isDownloaded);
  }

  Future<void> deleteModel(String modelId) async {
    // RunAnywhere SDK does not provide deleteModel directly.
  }

  List<ModelCategory> getModelCategories() {
    return [
      ModelCategory(
        name: 'Chat Models',
        icon: 'chat',
        models: [
          AtomModelConfig(id: 'llama3', name: 'Llama 3 8B', sizeBytes: 8000000000),
        ],
      ),
    ];
  }
}

class AtomModelConfig {
  final String id;
  final String name;
  final int sizeBytes;
  final String? quantization;

  AtomModelConfig({required this.id, required this.name, required this.sizeBytes, this.quantization});
}

class ModelCategory {
  final String name;
  final String icon;
  final List<AtomModelConfig> models;
  const ModelCategory({
    required this.name,
    required this.icon,
    required this.models,
  });
}
