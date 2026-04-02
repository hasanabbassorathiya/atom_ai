import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runanywhere/runanywhere.dart';
import 'model_service.dart';

class ActiveModelsState {
  final AtomModelConfig? chatModel;
  final AtomModelConfig? visionModel;
  final AtomModelConfig? sttModel;
  final AtomModelConfig? imageModel;
  final AtomModelConfig? embeddingModel;

  const ActiveModelsState({
    this.chatModel,
    this.visionModel,
    this.sttModel,
    this.imageModel,
    this.embeddingModel,
  });

  ActiveModelsState copyWith({
    AtomModelConfig? chatModel,
    AtomModelConfig? visionModel,
    AtomModelConfig? sttModel,
    AtomModelConfig? imageModel,
    AtomModelConfig? embeddingModel,
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

    // Updated to work with RunAnywhere-based AtomModelConfig
    Future<AtomModelConfig?> findIfDownloaded(String categoryName, String? preferredId) async {
      try {
        final categories = modelService.getModelCategories();
        final category = categories.firstWhere((c) => c.name == categoryName);

        if (preferredId != null) {
          final prefModel = category.models.firstWhere((m) => m.id == preferredId, orElse: () => category.models.first);
          if (await modelService.isDownloaded(prefModel.id)) {
            return prefModel;
          }
        }

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

    final chatModel = await findIfDownloaded('Chat Models', prefs.getString(_prefKeyChat));
    final visionModel = await findIfDownloaded('Vision Models', prefs.getString(_prefKeyVision));
    final sttModel = await findIfDownloaded('Speech-to-Text', prefs.getString(_prefKeyStt));
    final imageModel = await findIfDownloaded('Image Generation', prefs.getString(_prefKeyImage));
    final embeddingModel = await findIfDownloaded('Embeddings', prefs.getString(_prefKeyEmbedding));

    state = ActiveModelsState(
      chatModel: chatModel,
      visionModel: visionModel,
      sttModel: sttModel,
      imageModel: imageModel,
      embeddingModel: embeddingModel,
    );
  }

  Future<void> setVisionModel(AtomModelConfig model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyVision, model.id);
    state = state.copyWith(visionModel: model);
  }

  Future<void> setChatModel(AtomModelConfig model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyChat, model.id);
    state = state.copyWith(chatModel: model);
  }

  Future<void> setSttModel(AtomModelConfig model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyStt, model.id);
    state = state.copyWith(sttModel: model);
  }

  Future<void> setImageModel(AtomModelConfig model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyImage, model.id);
    state = state.copyWith(imageModel: model);
  }

  Future<void> setEmbeddingModel(AtomModelConfig model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyEmbedding, model.id);
    state = state.copyWith(embeddingModel: model);
  }
}

final activeModelsProvider = NotifierProvider<ActiveModelsNotifier, ActiveModelsState>(() {
  return ActiveModelsNotifier();
});
