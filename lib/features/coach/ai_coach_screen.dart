import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../core/widgets/illustrations.dart';
import 'ai_coach_chat_style.dart';
import 'ai_coach_provider.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  late final LlmProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = createAiCoachProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.2),
                  color: AppColors.softGray,
                ),
                child: const CustomPaint(
                  painter: RobotCoachPainter(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Coach',
                      style: GoogleFonts.pangolin(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inkText,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Always here to help',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.grayText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 1.2, color: AppColors.border),
        Expanded(
          child: LlmChatView(
            provider: _provider,
            style: aiCoachChatViewStyle(),
            welcomeMessage: aiCoachWelcomeMessage,
            suggestions: aiCoachSuggestions,
            enableAttachments: false,
            enableVoiceNotes: false,
          ),
        ),
      ],
    );
  }
}
