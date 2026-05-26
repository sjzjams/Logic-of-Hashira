import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

/// Gemini model id for Firebase AI Logic (Google AI endpoint).
const String aiCoachModelName = 'gemini-2.5-flash';

const String _coachSystemInstruction = '''
You are a supportive AI fitness coach in the Fitness Record app for the user Alex.
Give practical, encouraging advice about workouts, form, consistency, nutrition habits, sleep, and recovery.
Keep answers concise and actionable. Use a friendly tone.
Do not provide medical diagnoses or replace professional medical advice.
If asked about pain or injury, recommend consulting a healthcare professional.
''';

GenerativeModel createAiCoachGenerativeModel() {
  return FirebaseAI.googleAI().generativeModel(
    model: aiCoachModelName,
    systemInstruction: Content.system(_coachSystemInstruction),
  );
}

/// Builds the LLM provider for [AiCoachScreen].
///
/// Uses [FirebaseProvider] when [Firebase] is initialized (normal `main()`).
/// Falls back to [EchoProvider] in widget tests that pump [MyApp] without Firebase.
LlmProvider createAiCoachProvider() {
  if (Firebase.apps.isEmpty) {
    return EchoProvider();
  }
  return FirebaseProvider(model: createAiCoachGenerativeModel());
}

/// Suggested prompts shown when chat history is empty.
const List<String> aiCoachSuggestions = [
  'What should I focus on for bench press today?',
  'How can I improve my sleep for recovery?',
  'Suggest a light active recovery for rest day',
];

const String aiCoachWelcomeMessage =
    'Hey Alex! Ready to crush your training today? Ask me anything about workouts, form, or recovery.';
