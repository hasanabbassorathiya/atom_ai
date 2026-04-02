import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class AppSettings {
  final bool isDarkMode;
  final bool onboardingComplete;
  final int contextLength;
  final int numThreads;
  final bool useGpu;
  final double temperature;
  final double topP;
  final int voiceSilenceDuration;
  final String? selectedLlmModel;
  final String? selectedWhisperModel;

  const AppSettings({
    this.isDarkMode = false,
    this.onboardingComplete = false,
    this.contextLength = AppConstants.defaultContextLength,
    this.numThreads = AppConstants.defaultNumThreads,
    this.useGpu = true,
    this.temperature = AppConstants.defaultTemperature,
    this.topP = 0.9,
    this.voiceSilenceDuration = 1000,
    this.selectedLlmModel,
    this.selectedWhisperModel,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    bool? onboardingComplete,
    int? contextLength,
    int? numThreads,
    bool? useGpu,
    double? temperature,
    double? topP,
    int? voiceSilenceDuration,
    String? selectedLlmModel,
    String? selectedWhisperModel,
  }) =>
      AppSettings(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        contextLength: contextLength ?? this.contextLength,
        numThreads: numThreads ?? this.numThreads,
        useGpu: useGpu ?? this.useGpu,
        temperature: temperature ?? this.temperature,
        topP: topP ?? this.topP,
        voiceSilenceDuration: voiceSilenceDuration ?? this.voiceSilenceDuration,
        selectedLlmModel: selectedLlmModel ?? this.selectedLlmModel,
        selectedWhisperModel: selectedWhisperModel ?? this.selectedWhisperModel,
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      isDarkMode: prefs.getBool(AppConstants.keyThemeMode) ?? false,
      onboardingComplete:
          prefs.getBool(AppConstants.keyOnboardingComplete) ?? false,
      contextLength:
          prefs.getInt(AppConstants.keyContextLength) ?? AppConstants.defaultContextLength,
      numThreads:
          prefs.getInt(AppConstants.keyNumThreads) ?? AppConstants.defaultNumThreads,
      useGpu: prefs.getBool(AppConstants.keyUseGpu) ?? true,
      temperature: prefs.getDouble(AppConstants.keyTemperature) ?? AppConstants.defaultTemperature,
      topP: prefs.getDouble(AppConstants.keyTopP) ?? 0.9,
      voiceSilenceDuration: prefs.getInt(AppConstants.keyVoiceSilenceDuration) ?? 1000,
      selectedLlmModel: prefs.getString(AppConstants.keySelectedLlmModel),
      selectedWhisperModel: prefs.getString(AppConstants.keySelectedWhisperModel),
    );
  }

  Future<void> _save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyThemeMode, settings.isDarkMode);
    await prefs.setBool(AppConstants.keyOnboardingComplete, settings.onboardingComplete);
    await prefs.setInt(AppConstants.keyContextLength, settings.contextLength);
    await prefs.setInt(AppConstants.keyNumThreads, settings.numThreads);
    await prefs.setBool(AppConstants.keyUseGpu, settings.useGpu);
    await prefs.setDouble(AppConstants.keyTemperature, settings.temperature);
    await prefs.setDouble(AppConstants.keyTopP, settings.topP);
    await prefs.setInt(AppConstants.keyVoiceSilenceDuration, settings.voiceSilenceDuration);
    if (settings.selectedLlmModel != null) {
      await prefs.setString(AppConstants.keySelectedLlmModel, settings.selectedLlmModel!);
    }
    if (settings.selectedWhisperModel != null) {
      await prefs.setString(AppConstants.keySelectedWhisperModel, settings.selectedWhisperModel!);
    }
    state = AsyncValue.data(settings);
  }

  Future<void> setDarkMode(bool value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(isDarkMode: value));
  }

  Future<void> setOnboardingComplete() async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(onboardingComplete: true));
  }

  Future<void> setContextLength(int value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(contextLength: value));
  }

  Future<void> setNumThreads(int value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(numThreads: value));
  }

  Future<void> setUseGpu(bool value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(useGpu: value));
  }

  Future<void> setTemperature(double value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(temperature: value));
  }

  Future<void> setTopP(double value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(topP: value));
  }

  Future<void> setVoiceSilenceDuration(int value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(voiceSilenceDuration: value));
  }

  Future<void> setSelectedLlmModel(String modelId) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(selectedLlmModel: modelId));
  }
}
