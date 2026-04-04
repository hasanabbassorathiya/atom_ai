<<<<<<< HEAD
import 'dart:io' show Platform;

import 'package:atom_ai/domain/models/atom_model_config.dart';

/// Selects the best already-downloaded model for each modality.
class ModelSelector {
  const ModelSelector._();

  // ── LLM / Chat ─────────────────────────────────────────────────────────────

  static Future<ModelSelection> bestLlm() async {
    
    return ModelSelection(
      model: AtomModelConfig(id: 'llama3', name: 'Llama 3 8B', sizeBytes: 8000000000),
      needsDownload: false,
    );
=======
import 'dart:io';
import 'package:edge_veda/edge_veda.dart';


class ModelSelector {
  const ModelSelector._();
  static List<ModelInfo> get _llmPriority => Platform.isMacOS
      ? [ModelRegistry.llama31_8b, ModelRegistry.mistral_nemo_12b, ModelRegistry.phi35_mini, ModelRegistry.gemma2_2b, ModelRegistry.llama32_1b, ModelRegistry.qwen3_06b, ModelRegistry.tinyLlama]
      : [ModelRegistry.llama32_1b, ModelRegistry.gemma2_2b, ModelRegistry.phi35_mini, ModelRegistry.qwen3_06b, ModelRegistry.tinyLlama];
  static Future<ModelSelection> bestLlm([ModelManager? mm]) => _pick(_llmPriority, fallback: ModelRegistry.llama32_1b, mm: mm);
  static List<ModelInfo> get _visionPriority => Platform.isMacOS
      ? [ModelRegistry.qwen2vl_7b, ModelRegistry.llava16_mistral_7b, ModelRegistry.smolvlm2_500m, ModelRegistry.smolvlm2_256m]
      : [ModelRegistry.smolvlm2_256m, ModelRegistry.smolvlm2_500m];
  static Future<ModelSelection> bestVision([ModelManager? mm]) => _pickVision(_visionPriority, fallback: ModelRegistry.smolvlm2_500m, mm: mm);
  static List<ModelInfo> get _whisperPriority {
    if (Platform.isMacOS) return [ModelRegistry.whisperLargeV3, ModelRegistry.whisperMedium, ModelRegistry.whisperSmall, ModelRegistry.whisperBaseEn, ModelRegistry.whisperTinyEn];
    if (Platform.isAndroid) {
      final tier = DeviceProfile.detect().tier;
      if (tier.index <= DeviceTier.low.index) return [ModelRegistry.whisperTinyEn, ModelRegistry.whisperBaseEn];
      return [ModelRegistry.whisperBaseEn, ModelRegistry.whisperTinyEn, ModelRegistry.whisperSmall];
    }
    return [ModelRegistry.whisperBaseEn, ModelRegistry.whisperTinyEn, ModelRegistry.whisperSmall];
  }
  static Future<ModelSelection> bestWhisper([ModelManager? mm]) => _pick(_whisperPriority, fallback: ModelRegistry.whisperTinyEn, mm: mm);
  static List<ModelInfo> get _imagePriority => Platform.isMacOS
      ? [ModelRegistry.flux1Schnell, ModelRegistry.sdxlTurbo, ModelRegistry.sdV21Turbo]
      : [ModelRegistry.sdV21Turbo];
  static Future<ModelSelection> bestImageGen([ModelManager? mm]) => _pick(_imagePriority, fallback: ModelRegistry.sdV21Turbo, mm: mm);
  static List<ModelInfo> get _embeddingPriority => Platform.isMacOS
      ? [ModelRegistry.mxbaiEmbedLarge, ModelRegistry.nomicEmbedText, ModelRegistry.allMiniLmL6V2]
      : [ModelRegistry.allMiniLmL6V2, ModelRegistry.nomicEmbedText];
  static Future<ModelSelection> bestEmbedding([ModelManager? mm]) => _pick(_embeddingPriority, fallback: ModelRegistry.allMiniLmL6V2, mm: mm);
  static Future<ModelSelection> _pick(List<ModelInfo> candidates, {required ModelInfo fallback, ModelManager? mm}) async {
    final mgr = mm ?? ModelManager();
    for (final candidate in candidates) {
      if (await mgr.isModelDownloaded(candidate.id)) return ModelSelection(model: candidate, needsDownload: false);
    }
    return ModelSelection(model: fallback, needsDownload: true);
  }
  static Future<ModelSelection> _pickVision(List<ModelInfo> candidates, {required ModelInfo fallback, ModelManager? mm}) async {
    final mgr = mm ?? ModelManager();
    for (final candidate in candidates) {
      final mmproj = ModelRegistry.getMmprojForModel(candidate.id);
      final modelReady = await mgr.isModelDownloaded(candidate.id);
      final mmprojReady = mmproj == null || await mgr.isModelDownloaded(mmproj.id);
      if (modelReady && mmprojReady) return ModelSelection(model: candidate, mmproj: mmproj, needsDownload: false);
    }
    return ModelSelection(model: fallback, mmproj: ModelRegistry.getMmprojForModel(fallback.id), needsDownload: true);
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
  }
}
class ModelSelection {
<<<<<<< HEAD
  final AtomModelConfig model;
  final bool needsDownload;

  const ModelSelection({
    required this.model,
    required this.needsDownload,
  });
=======
  final ModelInfo model;
  final ModelInfo? mmproj;
  final bool needsDownload;
  const ModelSelection({required this.model, this.mmproj, required this.needsDownload});
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
}
