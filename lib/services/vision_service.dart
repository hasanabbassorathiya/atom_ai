import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/ai_interfaces.dart';
import 'vision_service_impl.dart';

final visionServiceProvider = Provider<VisionService>((ref) => VisionServiceImpl());
