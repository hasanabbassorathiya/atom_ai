# Atom AI - Roadmap

## Current Release Goal: v1.0.0

Ship a fully functional, offline-first, on-device AI app for iOS and Android with chat, voice, vision, image generation, document Q&A, and model management.

## What Is Being Built Now

### Phase 1: Core Shell & Infrastructure [DONE]
- App shell with Riverpod + GoRouter
- Design system (dark/light themes, typography, spacing)
- SQLite persistence for conversations and messages
- Settings service with SharedPreferences
- AI runtime service wrapping EdgeVeda + ChatSession
- Model service wrapping ModelManager + ModelRegistry

### Phase 2: Model Management [DONE]
- Model list grouped by capability
- Download with progress, cancellation, resume
- Delete downloaded models

### Phase 3: Chat Interface [DONE]
- Streaming chat with message bubbles
- Conversation history sidebar
- Auto-titling conversations
- Copy/share message actions
- Token count and latency display
- Session persistence to SQLite

### Phase 4-8: Feature Screens [Stubs Created]
- Voice, Vision, Image Gen, Documents screens — ready for implementation

## What Comes Next

### v1.1.0 — Voice & Vision
- [ ] Voice pipeline integration (STT → LLM → TTS)
- [ ] Microphone permission handling + visual feedback
- [ ] Camera integration for vision mode
- [ ] Gallery image pick for vision
- [ ] VLM model loading and inference

### v1.2.0 — Image Generation & Documents
- [ ] Stable Diffusion model loading
- [ ] Image generation with step progress
- [ ] Save/share generated images
- [ ] PDF/text file loading via file_picker
- [ ] RAG pipeline integration
- [ ] Document Q&A chat interface

## Medium-Term Roadmap

### v1.3.0 — Polish & Performance
- [ ] Onboarding flow with permission requests
- [ ] Loading skeletons and empty states
- [ ] Retry flows for failed operations
- [ ] Export/share for all content types
- [ ] Accessibility support (labels, semantics)
- [ ] Localization-ready structure (l10n)

### v1.4.0 — Advanced Features
- [ ] Tool/function calling integration
- [ ] Structured output with JSON schema
- [ ] Context summarization for long conversations
- [ ] Memory management with context overflow handling
- [ ] Thermal/battery-aware inference throttling

## Long-Term Roadmap

### v2.0.0 — Platform Maturity
- [ ] Widget/shortcut integration
- [ ] Background inference for notifications
- [ ] Multi-model concurrent loading
- [ ] Custom model import from local files
- [ ] Plugin architecture for extensions
- [ ] Cross-device sync (optional, encrypted)

## Known Dependencies and Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Edge Veda Android GPU support limited | Slower inference on Android | CPU fallback with thread optimization |
| Large model downloads (1-7GB) | Long first-run setup | Progress bars, resume, background download |
| Memory pressure on 4GB devices | OOM crashes | DeviceProfile tier detection, model advisor |
| TTS only on iOS natively | No voice output on Android | Platform TTS fallback via MethodChannel |
| Camera permission denial | Vision mode unusable | Graceful fallback to gallery pick |

## Release Milestones

| Version | Target | Key Deliverable |
|---------|--------|----------------|
| v1.0.0 | Now | Chat + Model Management + Settings |
| v1.1.0 | Next | Voice + Vision modes |
| v1.2.0 | After | Image Gen + Document Q&A |
| v1.3.0 | Medium | Polish, accessibility, l10n |
| v2.0.0 | Long | Platform maturity, plugins |

## Success Criteria

- [ ] All AI capabilities work offline
- [ ] Model download + inference on iPhone 13+ and Pixel 6+
- [ ] Chat streaming at 10+ tokens/sec on flagship devices
- [ ] App startup under 2 seconds (model already cached)
- [ ] Zero crashes during 1-hour continuous chat session
- [ ] Memory usage stays under device limit via DeviceProfile
- [ ] Privacy: zero network calls during inference
