import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/runanywhere_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AI Services
  final runAnywhereService = RunAnywhereService();
  await runAnywhereService.init();
  await runAnywhereService.loadModels();

  runApp(ProviderScope(
    overrides: [
      runAnywhereServiceProvider.overrideWithValue(runAnywhereService),
    ],
    child: const AtomAIApp(),
  ));
}
