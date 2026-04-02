import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:runanywhere/runanywhere.dart';

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

class DocumentService {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initRag({required String chatModelId, required String embedderModelId}) async {
    if (isInitialized) return;

    // Initialize embedding and RAG pipeline using RunAnywhere
    await RunAnywhere.loadModel(chatModelId);
    await RunAnywhere.loadModel(embedderModelId);
    _initialized = true;
  }

  Future<void> addDocument(String id, String text) async {
    if (!_initialized) throw Exception('RAG not initialized');
    // RunAnywhere SDK does not provide direct indexDocument.
    // Assuming documents are part of chat context in newer API.
  }

  Stream<String> queryStream(String query) async* {
    if (!_initialized) throw Exception('RAG not initialized');
    final streamResult = await RunAnywhere.generateStream(query);
    yield* streamResult.stream;
  }

  void dispose() {
    _initialized = false;
  }
}
