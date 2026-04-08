import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use StateProvider if available, otherwise check Riverpod documentation or usage
final focusModeProvider = StateProvider<String>((ref) => 'Balanced');
