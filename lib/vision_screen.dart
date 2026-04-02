import 'dart:io';
import 'dart:typed_data';
import 'package:edge_veda/edge_veda.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class VisionScreen extends StatefulWidget {
  const VisionScreen({super.key});

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  final _edgeVeda = EdgeVeda();
  final _modelManager = ModelManager();
  String _output = 'Initializing vision...';
  String? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final modelPath = await _modelManager.downloadModel(ModelRegistry.smolvlm2_500m);
    final mmprojPath = await _modelManager.downloadModel(ModelRegistry.smolvlm2_500m_mmproj);
    await _edgeVeda.initVision(VisionConfig(
      modelPath: modelPath, mmprojPath: mmprojPath,
    ));
    setState(() { _isLoading = false; _output = 'Ready! Pick an image.'; });
  }

  Future<void> _pickAndDescribe() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() { _imagePath = image.path; _isLoading = true; _output = 'Analyzing...'; });

    final bytes = await File(image.path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      setState(() { _output = 'Failed to decode selected image'; _isLoading = false; });
      return;
    }
    final rgb = Uint8List.fromList(decoded.getBytes(order: img.ChannelOrder.rgb));
    final result = await _edgeVeda.describeImage(
      rgb,
      width: decoded.width,
      height: decoded.height,
      prompt: 'Describe this image in detail.',
    );
    setState(() { _output = result; _isLoading = false; });
  }

  @override
  void dispose() {
    _edgeVeda.dispose();
    _modelManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vision')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_imagePath != null) Image.file(File(_imagePath!), height: 200),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(_output))),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndDescribe,
              child: Text(_isLoading ? 'Working...' : 'Pick Image'),
            ),
          ],
        ),
      ),
    );
  }
}
