import '../domain/services/ai_interfaces.dart';

final // runAnywhereServiceProvider = Provider<ChatService>((ref) => ChatServiceImpl());

class ChatServiceImpl implements ChatService {
  @override
  Future<Stream<String>> chatStream(String prompt) async {
    return Stream.value("AI Chat is temporarily unavailable.");
  }
}
