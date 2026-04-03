import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atom_ai/services/runanywhere_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Service initialization logic needs to be updated to match the new stubs
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Center(child: Text('Atom AI'))));
  }
}
