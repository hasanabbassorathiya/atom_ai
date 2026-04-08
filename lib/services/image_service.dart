import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/services/ai_interfaces.dart';
import 'image_service_impl.dart';

final imageServiceProvider = Provider<VisionService>((ref) => ImageServiceImpl());
