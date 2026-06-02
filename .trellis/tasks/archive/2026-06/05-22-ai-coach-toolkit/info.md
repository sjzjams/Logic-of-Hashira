# Task info — AI Coach Toolkit

## FlutterFire setup (assignee)

```bash
# Install CLI if needed: dart pub global activate flutterfire_cli
flutterfire configure
```

Produces `lib/firebase_options.dart`. See [Firebase + Flutter](https://firebase.google.com/docs/flutter/setup).

## Verify Coach tab

```bash
flutter pub get
flutter run
# Open Coach tab → send a message → expect streamed Gemini response
```

## Official toolkit entry

https://docs.flutter.dev/ai/ai-toolkit#get-started
