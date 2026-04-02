import 'dart:io' show Platform;

import 'package:runanywhere/runanywhere.dart';
import '../../services/model_service.dart';

/// Selects the best already-downloaded model for each modality.
class ModelSelector {
  const ModelSelector._();

  // ── LLM / Chat ─────────────────────────────────────────────────────────────

  static Future<ModelSelection> bestLlm() async {
    // Logic to select best LlamaCpp/Onnx model using RunAnywhere
    return const ModelSelection(
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
