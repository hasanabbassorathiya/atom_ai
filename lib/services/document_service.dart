import 'package:edge_veda/edge_veda.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_runtime_service.dart';
import 'model_service.dart';

final documentServiceProvider = Provider<DocumentService>((ref) {
  final runtime = ref.watch(aiRuntimeProvider.notifier);
  final modelService = ref.watch(modelServiceProvider);
  return DocumentService(runtime: runtime, modelService: modelService);
});

class DocumentService {
  final AiRuntimeNotifier _runtime;
  final ModelService _modelService;
  
  EdgeVeda? _embedder;
  RagPipeline? _ragPipeline;
  VectorIndex? _vectorIndex;
  FtsIndex? _ftsIndex;

  bool get isInitialized => _ragPipeline != null;

  DocumentService({
    required AiRuntimeNotifier runtime,
    required ModelService modelService,
  })  : _runtime = runtime,
        _modelService = modelService;

  Future<void> initRag({required String chatModelId, required String embedderModelId}) async {
    if (isInitialized) return;

    // We need the main LLM to be initialized to act as generator
    if (!_runtime.isInitialized || _runtime.currentModelId != chatModelId) {
      final chatModelPath = await _modelService.getModelPath(chatModelId);
      await _runtime.initWithModel(modelPath: chatModelPath, modelId: chatModelId);
    }

    // Load best embedder
    final embedderPath = await _modelService.getModelPath(embedderModelId);

    _embedder = EdgeVeda();
    await _embedder!.init(EdgeVedaConfig(
      modelPath: embedderPath,
      contextLength: 512,
    ));

    // For allMiniLmL6V2 it's 384, for nomic it's 768.
    // We can infer it from the model name roughly, or default.
    final dims = embedderModelId.contains('all-minilm') ? 384 : 768;

    _vectorIndex = VectorIndex(dimensions: dims);
    _ftsIndex = FtsIndex();

    _ragPipeline = RagPipeline.withModels(
      embedder: _embedder!,
      generator: _runtime.engine,
      index: _vectorIndex!,
      ftsIndex: _ftsIndex!,
      config: const RagConfig(
        topK: 2, // Reduced to prevent long prompt evaluation timeout
        minScore: 0.15,
        maxContextLength: 768, // Reduced from 2048 to prevent 2-minute timeout on CPU
        promptTemplate: _strictRagPromptTemplate,
      ),
    );
  }

  Future<void> addDocument(String id, String text, {required String chatModelId, required String embedderModelId}) async {
    if (!isInitialized) await initRag(chatModelId: chatModelId, embedderModelId: embedderModelId);

    // Chunk text to avoid exceeding 512 token embedding context
    final chunks = _chunkText(text, 1000); // ~200 words per chunk
    for (int i = 0; i < chunks.length; i++) {
      if (chunks[i].trim().isEmpty) continue;
      await _ragPipeline!.addDocument('${id}_$i', chunks[i]);
    }
  }

  List<String> _chunkText(String text, int chunkSize) {
    if (text.isEmpty) return [];
    final List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + chunkSize;
      if (end > text.length) {
        end = text.length;
      } else {
        // Try to break at a whitespace character to avoid cutting words
        int lastSpace = text.lastIndexOf(RegExp(r'\s'), end);
        if (lastSpace > start + (chunkSize ~/ 2)) {
          end = lastSpace;
        }
      }
      chunks.add(text.substring(start, end).trim());
      start = end;
    }
    return chunks;
  }

  Stream<TokenChunk> queryStream(String query) async* {
    if (!isInitialized) throw Exception('RAG not initialized');
    yield* _ragPipeline!.queryStream(query);
  }

  void dispose() {
    _embedder?.dispose();
    _embedder = null;
    _ragPipeline = null;
  }
}

const _strictRagPromptTemplate = '''
You are a helpful assistant that answers questions based strictly on the provided context.
If the context does not contain the answer, say "I don't have enough information in the documents to answer that."

Context:
{context}

Question: {query}
Answer:''';
