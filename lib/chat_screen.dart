import 'package:edge_veda/edge_veda.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _edgeVeda = EdgeVeda();
  final _modelManager = ModelManager();
  ChatSession? _session;
  final _messages = <Map<String, String>>[];
  final _controller = TextEditingController();
  bool _isLoading = true;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final modelPath = await _modelManager.downloadModel(ModelRegistry.llama32_1b);
    final device = DeviceProfile.detect();
    final scored = ModelAdvisor.score(
      model: ModelRegistry.llama32_1b, device: device, useCase: UseCase.chat,
    );
    await _edgeVeda.init(EdgeVedaConfig(
      modelPath: modelPath,
      contextLength: scored.recommendedConfig.contextLength,
      numThreads: scored.recommendedConfig.numThreads,
      useGpu: true,
    ));
    _session = ChatSession(edgeVeda: _edgeVeda);
    setState(() { _isLoading = false; _status = 'Ready'; });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _session == null) return;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _messages.add({'role': 'assistant', 'content': ''});
      _isLoading = true;
    });

    await for (final chunk in _session!.sendStream(text)) {
      if (!chunk.isFinal) {
        setState(() {
          _messages.last['content'] = (_messages.last['content'] ?? '') + chunk.token;
        });
      }
    }
    setState(() { _isLoading = false; });
  }

  @override
  void dispose() {
    _edgeVeda.dispose();
    _modelManager.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_status != 'Ready') Padding(
            padding: const EdgeInsets.all(16), child: Text(_status),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return ListTile(
                  title: Text(msg['content'] ?? ''),
                  leading: Icon(isUser ? Icons.person : Icons.smart_toy),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                  onSubmitted: (_) => _send(),
                )),
                IconButton(
                  onPressed: _isLoading ? null : _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
