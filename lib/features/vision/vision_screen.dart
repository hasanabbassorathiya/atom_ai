import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

import '../../services/vision_service.dart';
import 'package:atom_ai/domain/models/atom_model_config.dart';
import '../../services/active_models_service.dart';
import '../../core/widgets/model_selector_dropdown.dart';

class VisionScreen extends ConsumerStatefulWidget {
  final bool isActive;
  const VisionScreen({super.key, this.isActive = true});

  @override
  ConsumerState<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends ConsumerState<VisionScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  String _description = '';
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty || !mounted) return;

    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    try {
      await _cameraController!.initialize();
    } catch (e) {
      if (mounted) setState(() => _description = 'Camera error: $e');
      return;
    }

    if (mounted) setState(() => _isCameraReady = true);
  }

  Future<void> _analyzeFrame() async {
    if (!_isCameraReady || _isAnalyzing) return;
    setState(() => _isAnalyzing = true);

    try {
      final image = await _cameraController!.takePicture();

      final visionService = ref.read(visionServiceProvider);
      final activeModels = ref.read(activeModelsProvider);

      if (activeModels.visionModel == null) {
        throw Exception('Please select a Vision model first');
      }

      if (!visionService.isVisionInitialized) {
        await visionService.initVision(
          modelId: activeModels.visionModel!.id,
        );
      }

      final desc = await visionService.describeImage(
        image.path,
        prompt: 'Describe this image.',
      );
      setState(() => _description = desc);
    } catch (e) {
      setState(() => _description = 'Error: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: ModelSelectorDropdown(categoryType: ModelCategoryType.vision),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1 / _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Column(
              children: [
                if (_description.isNotEmpty)
                  Text(_description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeFrame,
                  icon: _isAnalyzing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.visibility),
                  label: Text(_isAnalyzing ? 'Analyzing...' : 'Describe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
