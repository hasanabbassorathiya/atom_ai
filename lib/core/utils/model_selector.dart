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
  }
}

/// Result of a [ModelSelector] query.
class ModelSelection {
  final AtomModelConfig model;
  final bool needsDownload;

  const ModelSelection({
    required this.model,
    required this.needsDownload,
  });
}
