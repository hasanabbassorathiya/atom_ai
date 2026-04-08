import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusModeNotifier extends Notifier<String> {
  @override
  String build() => 'Balanced';

  void setMode(String mode) {
    state = mode;
  }
}

final focusModeProvider = NotifierProvider<FocusModeNotifier, String>(FocusModeNotifier.new);
