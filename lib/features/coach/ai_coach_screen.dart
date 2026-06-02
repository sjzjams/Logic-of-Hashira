import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../../core/theme.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/prototype_page.dart';
import '../../firebase_options.dart';
import 'ai_coach_chat_style.dart';
import 'ai_coach_provider.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  LlmProvider? _provider;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (error) {
      if (error is UnsupportedError) {
        debugPrint('Firebase init skipped: ${error.message}');
      } else {
        debugPrint('Firebase init failed: $error');
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _provider = createAiCoachProvider();
      _isInitializing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final LlmProvider? provider = _provider;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
          child: Row(
            children: [
              Expanded(
                child: PrototypeHeader(
                  title: 'AI Coach',
                  kicker: _isInitializing ? 'Connecting...' : 'Build the chain',
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border, width: 1.2),
                  color: AppColors.softLilac,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.inkText.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const PrototypeIllustration(
                  assetId: 'coach_robot',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1.2, color: AppColors.border),
        Expanded(
          child: provider == null
              ? Container(
                  color: AppColors.canvas,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                )
              : Container(
                  color: AppColors.canvas,
                  child: LlmChatView(
                    provider: provider,
                    style: aiCoachChatViewStyle(),
                    welcomeMessage: aiCoachWelcomeMessage,
                    suggestions: aiCoachSuggestions,
                    enableAttachments: false,
                    enableVoiceNotes: false,
                  ),
                ),
        ),
      ],
    );
  }
}
