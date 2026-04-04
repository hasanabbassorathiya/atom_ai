<<<<<<< HEAD
=======
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

import 'package:edge_veda/edge_veda.dart';
>>>>>>> b71232a (Apply Stitch design system and configure Firebase App Distribution)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/atom_model_config.dart';

final modelServiceProvider = Provider<ModelService>((ref) => ModelService());

class ModelService {
  Future<void> ensureModel(String modelId) async {}
  Future<bool> isDownloaded(String modelId) async => true;
  Future<void> deleteModel(String modelId) async {}
  List<ModelCategory> getModelCategories() => [];
  
  // Method used by download_state.dart
  Stream<dynamic> get downloadProgress => Stream.empty();
}

class ModelCategory {
  final String name;
  final String icon;
  final List<AtomModelConfig> models;
  const ModelCategory({required this.name, required this.icon, required this.models});
}
