class AppConstants {
  static const String appName = 'Atom AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'On-device AI assistant. Private. Fast. Offline.';

  // Default inference settings
  static const int defaultContextLength = 2048;
  static const int defaultNumThreads = 4;
  static const int defaultMaxMemoryMb = 1536;
  static const int defaultMaxTokens = 512;
  static const double defaultTemperature = 0.7;

  // UI
  static const double maxChatWidth = 800;
  static const int maxConversationHistory = 100;

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyAutoDownload = 'auto_download';
  static const String keyContextLength = 'context_length';
  static const String keyNumThreads = 'num_threads';
  static const String keyUseGpu = 'use_gpu';
  static const String keyTemperature = 'temperature';
  static const String keyTopP = 'top_p';
  static const String keyVoiceSilenceDuration = 'voice_silence_duration';
  static const String keySelectedLlmModel = 'selected_llm_model';
  static const String keySelectedWhisperModel = 'selected_whisper_model';
}
