# Research: Flutter AI Toolkit for AiCoachScreen

**Sources**

- [Flutter AI Toolkit — Get started](https://docs.flutter.dev/ai/ai-toolkit#get-started)
- [Feature integration](https://docs.flutter.dev/ai/ai-toolkit/feature-integration)

---

## Summary

The official stack for prototyping is:

| Package | Role |
|---------|------|
| `flutter_ai_toolkit` | `LlmChatView`, chat UX, streaming, history |
| `firebase_core` | Firebase init in `main()` |
| `firebase_ai` | `FirebaseProvider` + `FirebaseAI.googleAI().generativeModel(...)` |

No API key in app code when using Firebase AI Logic; project config via **FlutterFire** (`firebase_options.dart`).

---

## Integration shape for this app

Current `AiCoachScreen` is a `Column`: custom header (RobotCoach) + mock `ListView` + custom input bar.

**Recommended MVP layout**

```
Column
├── Existing coach header (RobotCoach + title)   ← keep hand-drawn brand
└── Expanded(
      child: LlmChatView(
        provider: FirebaseProvider(...),
        welcomeMessage: '...',
        suggestions: [...],  // fitness prompts
        // style: match AppColors via toolkit custom styling (Phase 2 polish)
      ),
    )
```

Remove mock `_messages`, `_sendMessage`, `TextEditingController` once `LlmChatView` owns input.

---

## `main.dart` changes (required)

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
runApp(const MyApp());
```

Requires `lib/firebase_options.dart` from `flutterfire configure` (user/machine step).

---

## Coach-specific toolkit features

| Feature | Use in fitness coach |
|---------|----------------------|
| `welcomeMessage` | Greeting aligned with current copy (“Hey Alex…”) |
| `suggestions` | e.g. bench form, today's workout, sleep recovery |
| `systemInstruction` on `generativeModel` | Fitness coach persona, safety disclaimers, no medical diagnosis |
| `disableAttachments` / audio | MVP: disable until product asks |
| Custom styling | Map `AppColors.inkBlue`, borders, fonts where API allows |
| Chat history / serialization | Optional post-MVP |

---

## Platform & permissions

- **Android**: `INTERNET` in manifest (likely already present).
- **macOS**: network client entitlement if building for macOS.
- Voice/media: skip for MVP per feature-integration doc optional plugins.

---

## Security (from official docs)

- Do **not** commit `firebase_options.dart` to a **public** repo without understanding quota/billing exposure.
- Production: prefer backend proxy; MVP may use client-side Gemini for prototyping with private repo or restricted Firebase rules.

Add `firebase_options.dart` to `.gitignore` if team chooses secrets-out-of-repo pattern; document in PRD.

---

## Risks

| Risk | Mitigation |
|------|------------|
| No Firebase project yet | Blocker: user runs `flutterfire configure` before implement |
| `LlmChatView` default theme clashes with hand-drawn UI | MVP functional integration first; follow-up task for full style parity |
| Widget tests need Firebase mock | Test header + provider wiring; mock provider or skip LLM in CI |

---

## Out of scope (this research)

- Vertex AI production endpoint (use `googleAI()` for MVP).
- Custom non-Firebase `LlmProvider` implementation.
- Voice input and file attachments.
