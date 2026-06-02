# Integrate Flutter AI Toolkit — AiCoachScreen

## Goal

Replace the **mock chat** in `lib/features/coach/ai_coach_screen.dart` with a real LLM-backed chat using the official **[Flutter AI Toolkit](https://docs.flutter.dev/ai/ai-toolkit#get-started)** (`LlmChatView` + `FirebaseProvider`), while keeping the existing hand-drawn coach header (RobotCoach, “AI Coach”, online indicator).

## Background

| Current | Target |
|---------|--------|
| Local `_messages` list + `Future.delayed` fake replies | Streaming multiturn chat via `flutter_ai_toolkit` |
| Custom `ListView` + `TextField` input bar | `LlmChatView` handles input, streaming, history |
| No Firebase | `firebase_core` + `firebase_ai` + FlutterFire config |

Reference implementation: [Get started](https://docs.flutter.dev/ai/ai-toolkit#get-started), [Feature integration](https://docs.flutter.dev/ai/ai-toolkit/feature-integration).  
Research: [research/flutter-ai-toolkit.md](./research/flutter-ai-toolkit.md).

---

## MVP scope (in)

1. **Dependencies** (`pubspec.yaml`):
   - `flutter_ai_toolkit` (latest compatible)
   - `firebase_core`
   - `firebase_ai`

2. **Firebase bootstrap**
   - `WidgetsFlutterBinding.ensureInitialized()` + `Firebase.initializeApp` in `main.dart`
   - `lib/firebase_options.dart` generated via FlutterFire CLI (document manual step in README snippet)
   - `.gitignore` entry for `firebase_options.dart` **if** team keeps it local-only (confirm with assignee)

3. **`AiCoachScreen` refactor**
   - Keep top header row (`RobotCoachPainter`, title, “Always here to help”).
   - Replace chat list + bottom input with `Expanded(child: LlmChatView(...))`.
   - `FirebaseProvider` with `FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash')` (or current doc-default model name).
   - `welcomeMessage` + `suggestions` (3–4 fitness prompts).
   - `systemInstruction` on model: friendly fitness coach for user “Alex”; no medical advice; encourage safe training.

4. **Provider wiring**
   - Extract provider factory to `lib/features/coach/ai_coach_provider.dart` (or `lib/core/ai/`) so screen stays readable and testable.

5. **Docs**
   - Short “Firebase setup” subsection in `README.md` or task `info.md`.
   - Update `docs/CODE_WIKI.md` Coach section (mock → Firebase toolkit).

6. **Quality**
   - `flutter analyze` clean
   - `flutter test` passes (extend widget test: Coach tab shows “AI Coach”; avoid live LLM calls in tests)

---

## Out of scope (MVP)

- Vertex AI production endpoint
- Custom `LlmProvider` (non-Firebase OpenAI/etc.)
- Voice input, attachments, function calling
- Full visual parity of `LlmChatView` bubbles with `HandDrawnCard` (follow-up polish task)
- Chat persistence across app restarts (toolkit supports it; defer)
- Backend proxy for API keys

---

## Acceptance criteria

- [x] User opens **Coach** tab and sees existing header + working chat UI from toolkit
- [x] Sending a message returns a **real streamed** model response (device/emulator with network + valid Firebase project)
- [x] No mock `Future.delayed` coach replies remain
- [x] App launches after `Firebase.initializeApp` without crash (with valid `firebase_options.dart`)
- [x] `flutter analyze` and `flutter test` pass
- [x] CODE_WIKI Coach / dependencies sections updated

---

## Prerequisites (human / assignee)

Before **Phase 2 implement** completes end-to-end testing:

1. Create or select a **Firebase project** with AI Logic / Gemini enabled.
2. From repo root: `flutterfire configure` → generates `lib/firebase_options.dart`.
3. Confirm billing/quota acceptable for dev testing.

If Firebase is not configured, implementer may land code behind a clear error state or README blocker (no silent mock fallback).

---

## Technical notes

- `LayoutShell` embeds `AiCoachScreen` in `IndexedStack`; provider lifecycle should be per-screen or app-level as recommended by toolkit (prefer screen-level `StatefulWidget` holding provider if recreation is costly).
- Dispose: remove old `TextEditingController` when removing mock input.
- Model id: use documented default from Flutter AI Toolkit get-started; pin in one constant.

---

## Open decisions

| # | Question | Default if no answer |
|---|----------|-------------------|
| 1 | Is Firebase / FlutterFire already configured on your machine? | Implement code paths; document setup; assignee runs `flutterfire configure` |
| 2 | Commit `firebase_options.dart` or gitignore? | **Gitignore** + example `firebase_options.example.dart` template (safer for public repos) |

---

## Related files

- `lib/features/coach/ai_coach_screen.dart`
- `lib/main.dart`
- `pubspec.yaml`
- `lib/features/layout_shell.dart` (tab host, unchanged behavior)
- `test/widget_test.dart`

---

## Status

- [x] Task created (`05-22-ai-coach-toolkit`)
- [x] Research written
- [x] Assignee confirms Firebase readiness (A — self-test on device)
- [x] `implement.jsonl` / `check.jsonl` curated
- [x] Phase 2 implement (code landed; run `flutterfire configure` before device test)
- [x] Assignee device verification with real Gemini
- [x] Phase 3 completed
