import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edge_veda/edge_veda.dart';

final modelServiceProvider = Provider<ModelService>((ref) => ModelService());

class ModelService {
  final ModelManager _manager = ModelManager();
  final Map<String, CancelToken> _cancelTokens = {};
  final StreamController<(String, DownloadProgress)> _progressStreamController = StreamController.broadcast();

  ModelManager get manager => _manager;

  Future<List<ModelInfo>> getAvailableModels() async {
    return [
      ...ModelRegistry.getAllModels(),
      ...ModelRegistry.getVisionModels(),
      ...ModelRegistry.getWhisperModels(),
      ...ModelRegistry.getImageModels(),
      ...ModelRegistry.getEmbeddingModels(),
    ];
  }

  Future<bool> isDownloaded(String modelId) => _manager.isModelDownloaded(modelId);

  Future<String> downloadModel(ModelInfo model) async {
    final token = CancelToken();
    _cancelTokens[model.id] = token;

    // Subscribe to manager progress and pipe to our specialized stream
    final sub = _manager.downloadProgress.listen((progress) {
      _progressStreamController.add((model.id, progress));
    });

    try {
      return await _manager.downloadModel(model, cancelToken: token);
    } finally {
      sub.cancel();
      _cancelTokens.remove(model.id);
    }
  }

  void cancelDownload(String modelId) {
    _cancelTokens[modelId]?.cancel();
    _cancelTokens.remove(modelId);
  }

  Future<void> deleteModel(String modelId) => _manager.deleteModel(modelId);
  Future<String> getModelPath(String modelId) => _manager.getModelPath(modelId);

  Stream<(String, DownloadProgress)> get modelProgress => _progressStreamController.stream;
}
