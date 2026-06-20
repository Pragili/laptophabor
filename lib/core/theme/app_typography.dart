import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Major-Third (1.25) type scale on Inter — mirrors Section B2.
class AppType {
  static TextTheme textTheme(TextTheme base) {
    TextStyle s(double size, FontWeight w, {Color color = AppColors.textPrimary, double? h}) =>
        GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, height: h);

    return base.copyWith(
      displayLarge: s(32, FontWeight.w700),
      headlineLarge: s(26, FontWeight.w700),
      headlineMedium: s(22, FontWeight.w600),
      titleLarge: s(18, FontWeight.w600),
      titleMedium: s(16, FontWeight.w500),
      bodyLarge: s(16, FontWeight.w400),
      bodyMedium: s(14, FontWeight.w400),
      labelLarge: s(14, FontWeight.w600),
      bodySmall: s(12, FontWeight.w400, color: AppColors.textSecondary),
      labelSmall: s(11, FontWeight.w600, color: AppColors.textSecondary),
    );
  }
}
