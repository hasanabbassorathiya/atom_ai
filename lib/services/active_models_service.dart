import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edge_veda/edge_veda.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model_service.dart';

class ActiveModelsState {
  final ModelInfo? chatModel;
  final ModelInfo? visionModel;
  final ModelInfo? sttModel;
  final ModelInfo? imageModel;
  final ModelInfo? embeddingModel;

  const ActiveModelsState({
    this.chatModel,
    this.visionModel,
    this.sttModel,
    this.imageModel,
    this.embeddingModel,
  });

  ActiveModelsState copyWith({
    ModelInfo? chatModel,
    ModelInfo? visionModel,
    ModelInfo? sttModel,
    ModelInfo? imageModel,
    ModelInfo? embeddingModel,
  }) {
    return ActiveModelsState(
      chatModel: chatModel ?? this.chatModel,
      visionModel: visionModel ?? this.visionModel,
      sttModel: sttModel ?? this.sttModel,
      imageModel: imageModel ?? this.imageModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
    );
  }
}

class ActiveModelsNotifier extends Notifier<ActiveModelsState> {
  static const _prefKeyChat = 'active_model_chat';
  static const _prefKeyVision = 'active_model_vision';
  static const _prefKeyStt = 'active_model_stt';
  static const _prefKeyImage = 'active_model_image';
  static const _prefKeyEmbedding = 'active_model_embedding';

  @override
  ActiveModelsState build() {
    _loadInitialModels();
    return const ActiveModelsState();
  }

  Future<void> _loadInitialModels() async {
    final modelService = ref.read(modelServiceProvider);
    final prefs = await SharedPreferences.getInstance();
    
    // Quick helper to find a model by ID if it's downloaded
    Future<ModelInfo?> findIfDownloaded(String categoryIcon, String? preferredId) async {
      try {
        final category = modelService.getModelCategories().firstWhere((c) => c.icon == categoryIcon);
        
        // If we have a preferred ID from prefs, check if it's downloaded
        if (preferredId != null) {
          final prefModel = category.models.firstWhere((m) => m.id == preferredId, orElse: () => category.models.first);
          if (await modelService.isDownloaded(prefModel.id)) {
            return prefModel;
          }
        }

        // Fallback: pick the first downloaded model in this category
        for (final model in category.models) {
          if (await modelService.isDownloaded(model.id)) {
            return model;
          }
        }
      } catch (e) {
        // ignore
      }
      return null;
    }

    final chatModel = await findIfDownloaded('chat', prefs.getString(_prefKeyChat));
    final visionModel = await findIfDownloaded('visibility', prefs.getString(_prefKeyVision));
    final sttModel = await findIfDownloaded('mic', prefs.getString(_prefKeyStt));
    final imageModel = await findIfDownloaded('image', prefs.getString(_prefKeyImage));
    final embeddingModel = await findIfDownloaded('hub', prefs.getString(_prefKeyEmbedding));

    state = ActiveModelsState(
      chatModel: chatModel,
      visionModel: visionModel,
      sttModel: sttModel,
      imageModel: imageModel,
      embeddingModel: embeddingModel,
    );
  }

  Future<void> setChatModel(ModelInfo model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyChat, model.id);
    state = state.copyWith(chatModel: model);
  }

  Future<void> setVisionModel(ModelInfo model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyVision, model.id);
    state = state.copyWith(visionModel: model);
  }

  Future<void> setSttModel(ModelInfo model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyStt, model.id);
    state = state.copyWith(sttModel: model);
  }

  Future<void> setImageModel(ModelInfo model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyImage, model.id);
    state = state.copyWith(imageModel: model);
  }

  Future<void> setEmbeddingModel(ModelInfo model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyEmbedding, model.id);
    state = state.copyWith(embeddingModel: model);
  }
}

final activeModelsProvider = NotifierProvider<ActiveModelsNotifier, ActiveModelsState>(() {
  return ActiveModelsNotifier();
});
