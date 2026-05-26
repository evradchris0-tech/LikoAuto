import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie validée — Inter (fallback Poppins).
abstract final class AppTypography {
  static TextTheme buildTextTheme(Color onSurface, Color onSurfaceVariant) {
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      // Headings
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: onSurface,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurface,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurface,
      ),
      // Body
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: onSurfaceVariant,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: onSurfaceVariant,
      ),
      // Labels (boutons, badges)
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: onSurfaceVariant,
      ),
    );
  }
}
