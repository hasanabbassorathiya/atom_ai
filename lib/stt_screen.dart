import 'dart:async';
import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';
import 'package:flutter/material.dart';

class SttScreen extends StatefulWidget {
  const SttScreen({super.key});

  @override
  State<SttScreen> createState() => _SttScreenState();
}

class _SttScreenState extends State<SttScreen> {
  final _modelManager = ModelManager();
  String? _modelPath;
  WhisperSession? _whisper;
  StreamSubscription<WhisperSegment>? _segmentSubscription;
  StreamSubscription<Float32List>? _audioSubscription;
  String _transcript = 'Tap microphone to start...';
  bool _isRecording = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    _modelPath = await _modelManager.downloadModel(ModelRegistry.whisperBaseEn);
    setState(() { _isLoading = false; });
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _audioSubscription?.cancel();
      _audioSubscription = null;
      await _whisper?.flush();
      await _whisper?.stop();
      await _segmentSubscription?.cancel();
      _segmentSubscription = null;
      setState(() { _isRecording = false; });
    } else {
      if (_modelPath == null) return;
      final granted = await WhisperSession.requestMicrophonePermission();
      if (!granted) {
        setState(() { _transcript = 'Microphone permission denied'; });
        return;
      }
      _whisper = WhisperSession(modelPath: _modelPath!);
      await _whisper!.start();
      await _segmentSubscription?.cancel();
      _segmentSubscription = _whisper!.onSegment.listen((segment) {
        setState(() { _transcript = _whisper!.transcript; });
      });
      _audioSubscription = WhisperSession.microphone().listen((samples) {
        _whisper?.feedAudio(samples);
      });
      setState(() { _isRecording = true; _transcript = ''; });
    }
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _segmentSubscription?.cancel();
    _whisper?.dispose();
    _modelManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(_transcript, style: const TextStyle(fontSize: 18)),
              ),
            ),
            FloatingActionButton(
              onPressed: _isLoading ? null : _toggleRecording,
              child: Icon(_isRecording ? Icons.stop : Icons.mic),
            ),
          ],
        ),
      ),
    );
  }
}
