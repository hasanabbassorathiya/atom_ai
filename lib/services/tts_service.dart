import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/ai_interfaces.dart';
import 'tts_service_impl.dart';

final ttsServiceProvider = Provider<TtsService>((ref) => TtsServiceImpl());
