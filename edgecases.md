# Atom AI - Edge Cases Register

## Low RAM Devices
- **Scenario**: User has a device with 3-4GB RAM
- **Impact**: Model loading fails or OOM during inference
- **Detection**: `DeviceProfile.detect()` classifies tier; `MemoryEstimator` checks fit
- **Mitigation**: Auto-select smaller models (TinyLlama, Qwen3 0.6B); reduce context length; show warning before loading large models
- **User-facing behavior**: "This model may be too large for your device. Try a smaller model."
- **Test strategy**: Test on iPhone SE (3GB); artificially reduce `maxMemoryMb`

## Thermal Throttling
- **Scenario**: Extended inference causes device to overheat
- **Impact**: CPU/GPU throttled, inference slows dramatically
- **Detection**: `TelemetryService.getThermalState()` returns 2 (serious) or 3 (critical)
- **Mitigation**: `Scheduler` + `RuntimePolicy` degrade QoS; reduce threads; pause image generation
- **User-facing behavior**: "Device is warm. Inference speed reduced to protect your device."
- **Test strategy**: Run soak test (continuous generation for 30+ minutes); monitor thermal state

## Battery Saver Mode
- **Scenario**: Device enters low power mode
- **Impact**: Reduced CPU frequency, GPU may be disabled
- **Detection**: `TelemetryService.getBatteryState()` detects low power mode
- **Mitigation**: `Scheduler` reduces thread count and pauses background work
- **User-facing behavior**: "Battery saver active. Inference may be slower."
- **Test strategy**: Enable low power mode; verify inference still works at reduced speed

## Interrupted Downloads
- **Scenario**: Network drops during model download (668MB - 7GB files)
- **Impact**: Partial .tmp file on disk
- **Detection**: `ModelManager` tracks download state via .tmp file presence
- **Mitigation**: Resume download from last byte (HTTP Range header); keep .tmp for retry
- **User-facing behavior**: Progress bar resumes from where it stopped
- **Test strategy**: Kill network mid-download; restart; verify resume works

## Partial Model Availability
- **Scenario**: Chat model downloaded but vision/whisper models missing
- **Impact**: Some features unavailable
- **Detection**: `ModelManager.isModelDownloaded()` per model ID
- **Mitigation**: Show feature-specific empty states; guide user to Models tab
- **User-facing behavior**: "Download a Vision model to use this feature"
- **Test strategy**: Fresh install with only LLM downloaded; verify all screens handle gracefully

## Corrupted Model Files
- **Scenario**: Model file corrupted (disk error, interrupted rename)
- **Impact**: `evInit` fails with model load error
- **Detection**: SHA256 checksum verification in `ModelManager`
- **Mitigation**: Delete corrupted file; re-download; `ModelValidationException` caught
- **User-facing behavior**: "Model file corrupted. Re-downloading..."
- **Test strategy**: Truncate a .gguf file; attempt init; verify error handling

## App Backgrounding During Inference
- **Scenario**: User switches apps while model is generating
- **Impact**: iOS may kill the app; isolate may be suspended
- **Detection**: `WidgetsBindingObserver.didChangeAppLifecycleState`
- **Mitigation**: Save partial output; allow resume; don't crash on isolate suspension
- **User-facing behavior**: Partial response preserved when returning to app
- **Test strategy**: Start generation; switch to another app for 30s; return

## Long Conversation Context Overflow
- **Scenario**: Conversation exceeds model's context window (2048-8192 tokens)
- **Impact**: Older context lost; model generates incoherent responses
- **Detection**: `ChatSession.contextUsage` tracks percentage
- **Mitigation**: `ChatSession` auto-summarizes older messages when context fills
- **User-facing behavior**: Seamless — user doesn't notice context management
- **Test strategy**: Send 50+ messages in one conversation; verify coherence maintained

## Streaming Interruption
- **Scenario**: Streaming generation interrupted (cancel, crash, timeout)
- **Impact**: Partial response displayed
- **Detection**: `CancelToken.isCancelled`; stream error handling
- **Mitigation**: Save partial text; show it with "interrupted" indicator; allow retry
- **User-facing behavior**: Partial response visible; retry button available
- **Test strategy**: Cancel mid-generation; verify partial text preserved

## Speech Recognition Failures
- **Scenario**: Whisper fails to transcribe (noisy environment, unsupported language)
- **Impact**: Empty or garbage transcript
- **Detection**: Empty string result or very low confidence
- **Mitigation**: Show "Couldn't understand" message; allow retry; suggest quieter environment
- **User-facing behavior**: "I didn't catch that. Try again in a quieter place."
- **Test strategy**: Send silence/noise audio; verify graceful handling

## TTS Failures
- **Scenario**: Text-to-speech fails (no voice available, audio session conflict)
- **Impact**: No audio output for assistant response
- **Detection**: `TtsEvent.cancel` event; platform exception
- **Mitigation**: Fallback to text-only display; show error toast
- **User-facing behavior**: Response shown as text only
- **Test strategy**: Disable system voices; test TTS; verify text fallback

## Permission Denial
- **Scenario**: User denies microphone, camera, or storage permissions
- **Impact**: Voice mode, vision mode, or file operations fail
- **Detection**: `permission_handler` status check
- **Mitigation**: Show explanation and link to settings; disable affected features gracefully
- **User-facing behavior**: "Microphone access needed for voice mode. Tap to open Settings."
- **Test strategy**: Deny each permission; verify screen shows guidance

## No Storage Space
- **Scenario**: Device full when downloading model or saving conversation
- **Impact**: Download fails; database write fails
- **Detection**: `TelemetryService.getFreeDiskSpace()` checked before download
- **Mitigation**: Show disk usage; suggest deleting unused models; abort download early
- **User-facing behavior**: "Not enough storage. Free 500MB to download this model."
- **Test strategy**: Fill device; attempt download; verify error message

## Offline Startup
- **Scenario**: App launched with no network; models already cached
- **Impact**: None — app works fully offline
- **Detection**: N/A — this is the designed primary mode
- **Mitigation**: All inference is local; only model downloads need network
- **User-facing behavior**: App works identically offline and online
- **Test strategy**: Airplane mode; launch app; chat; verify full functionality

## App Kill and Recovery
- **Scenario**: iOS kills app for memory; user reopens
- **Impact**: All in-memory state lost; isolate workers terminated
- **Detection**: `initState` lifecycle; database persistence
- **Mitigation**: Conversations persisted to SQLite; model re-loaded on demand
- **User-facing behavior**: Previous conversations available; model reloads automatically
- **Test strategy**: Force kill; reopen; verify conversations intact

## iOS and Android Differences
- **Scenario**: Different capabilities per platform
- **Impact**: Metal GPU on iOS, CPU-only on Android; TTS availability differs
- **Detection**: `Platform.isIOS` / `Platform.isAndroid`
- **Mitigation**: `DeviceProfile.detect()` adapts settings; platform-specific UI messaging
- **User-facing behavior**: Features clearly indicate when platform-limited
- **Test strategy**: Test on both platforms; verify all screens work

## Model Mismatch
- **Scenario**: User tries to use chat model for vision, or embedding model for chat
- **Impact**: Garbage output or crash
- **Detection**: Model capability tags in `ModelRegistry`
- **Mitigation**: Only show compatible models per feature; validate at init time
- **User-facing behavior**: Clear model categorization in Models screen
- **Test strategy**: Attempt to load wrong model type; verify error handling

## Empty or Malformed Model Output
- **Scenario**: Model generates empty string, repetitive text, or malformed JSON
- **Impact**: User sees no response or garbage
- **Detection**: Empty response check; `TextCleaner` post-processing
- **Mitigation**: Show "Model produced no output" message; allow retry; adjust temperature
- **User-facing behavior**: "No response generated. Try rephrasing your question."
- **Test strategy**: Use very short context that triggers empty output

## Cancellation and Retry Behavior
- **Scenario**: User cancels generation then immediately retries
- **Impact**: Potential race condition between cancel and new generation
- **Detection**: `_isStreaming` guard; `CancelToken` lifecycle
- **Mitigation**: Wait for stream cleanup before starting new generation
- **User-facing behavior**: Cancel button stops immediately; send re-enables
- **Test strategy**: Rapid cancel-retry cycles; verify no crashes

## Memory Leaks
- **Scenario**: Repeated model load/unload cycles leak native memory
- **Impact**: Gradual memory growth; eventual OOM
- **Detection**: `MemoryStats.peakBytes` tracking; native `evFree` cleanup
- **Mitigation**: All native resources freed in `dispose()`; isolate cleanup verified
- **User-facing behavior**: None if working correctly
- **Test strategy**: Load/unload model 20 times; monitor memory stats

## Concurrency Races
- **Scenario**: Two generate calls overlap
- **Impact**: Undefined behavior; potential crash
- **Detection**: `_isStreaming` flag; `GenerationException` thrown
- **Mitigation**: Only one streaming operation at a time; UI disables send during generation
- **User-facing behavior**: Send button disabled while generating
- **Test strategy**: Rapidly tap send; verify only one generation runs

## Audio Focus Conflicts
- **Scenario**: Music playing when TTS speaks; incoming call during voice mode
- **Impact**: Audio mixed or interrupted
- **Detection**: `AVAudioSession` configuration in native plugin
- **Mitigation**: VoicePipeline configures audio session for simultaneous capture/playback
- **User-facing behavior**: TTS ducks music; phone call pauses voice mode
- **Test strategy**: Play music; start voice mode; verify behavior

## File Picker Failures
- **Scenario**: File picker cancelled; unsupported file selected
- **Impact**: No file loaded; processing fails
- **Detection**: Null result from `FilePicker.platform.pickFiles()`
- **Mitigation**: Validate file type and size; show supported formats list
- **User-facing behavior**: "Unsupported file type. Try PDF or TXT."
- **Test strategy**: Cancel picker; select unsupported file; verify handling

## Image Generation Failures
- **Scenario**: SD model fails mid-generation (memory, thermal, corrupted model)
- **Impact**: No image produced; potential crash
- **Detection**: `ImageGenerationException`; `ImageWorker` error responses
- **Mitigation**: Catch and display error; clean up worker; allow retry
- **User-facing behavior**: "Image generation failed. Try again with fewer steps."
- **Test strategy**: Generate during high memory pressure; verify error handling

## First-Run Onboarding Failures
- **Scenario**: Onboarding skipped or interrupted
- **Impact**: No model downloaded; app non-functional for AI features
- **Detection**: `onboardingComplete` flag in SharedPreferences
- **Mitigation**: Chat screen auto-downloads default model if none present
- **User-facing behavior**: "Downloading default model..." on first chat attempt
- **Test strategy**: Skip onboarding; go directly to chat; verify model auto-downloads

## Privacy and Data Retention
- **Scenario**: User wants to delete all data
- **Impact**: All conversations, settings, models cleared
- **Detection**: Explicit user action in Settings
- **Mitigation**: Clear database, SharedPreferences, model cache directory
- **User-facing behavior**: "Delete All Data" button with confirmation dialog
- **Test strategy**: Delete all data; verify clean state; app restarts normally
