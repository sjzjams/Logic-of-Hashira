import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';

/// Hand-drawn-adjacent styling for [LlmChatView] on the coach tab.
LlmChatViewStyle aiCoachChatViewStyle() {
  final borderRadius = BorderRadius.circular(16);
  final border = Border.all(color: AppColors.border, width: 1.2);

  return LlmChatViewStyle(
    backgroundColor: Colors.white,
    progressIndicatorColor: AppColors.inkBlue,
    userMessageStyle: UserMessageStyle(
      textStyle: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.inkText,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.inkBlue, width: 1.6),
        borderRadius: borderRadius,
      ),
    ),
    llmMessageStyle: LlmMessageStyle(
      iconColor: AppColors.inkBlue,
      decoration: BoxDecoration(
        color: AppColors.softLilac.withValues(alpha: 0.35),
        border: border,
        borderRadius: borderRadius,
      ),
    ),
    chatInputStyle: ChatInputStyle(
      hintText: 'Ask your coach anything...',
      textStyle: GoogleFonts.nunito(fontSize: 15, color: AppColors.inkText),
      hintStyle: GoogleFonts.nunito(fontSize: 14, color: AppColors.grayText),
      backgroundColor: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
        borderRadius: borderRadius,
      ),
    ),
    submitButtonStyle: ActionButtonStyle(
      iconColor: Colors.white,
      iconDecoration: BoxDecoration(
        color: AppColors.inkBlue,
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.inkBlue, width: 1.2),
      ),
    ),
    suggestionStyle: SuggestionStyle(
      textStyle: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.inkBlue,
      ),
      decoration: BoxDecoration(
        color: AppColors.softLilac,
        border: Border.all(color: AppColors.inkBlue.withValues(alpha: 0.3)),
        borderRadius: borderRadius,
      ),
    ),
  );
}
