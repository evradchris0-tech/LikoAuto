import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme buildTextTheme(Color onSurface, Color onSurfaceVariant) {
    final base = ThemeData.light().textTheme;

    return base.copyWith(
      // ── Display — utilisé uniquement pour displaySmall (login, register) ──
      // displayLarge / displayMedium volontairement omis : non utilisés.
      displaySmall: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: -1,
        color: onSurface,
      ),

      // ── Headline — titres de section et AppBar (Montserrat) ───────────────
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.8,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.4,
        color: onSurface,
      ),

      // ── Title — titres de cards, items de liste (System Font) ─────────────
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600, // w500 ≠ labelLarge w700 → distinction claire
        height: 1.4,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: -0.2,
        color: onSurface,
      ),

      // ── Body — texte courant (System Font) ─────────────────────────────────
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13, // 13sp (était 14sp — écart imperceptible avec bodyLarge 15sp)
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: -0.2,
        color: onSurfaceVariant,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12, // minimum WCAG
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: -0.1,
        color: onSurfaceVariant,
      ),

      // ── Label — boutons, nav, badges interactifs (System Font) ────────────
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w800, // w700 ≠ titleMedium w500 → clairement interactif
        height: 1.2,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 12, // 12sp minimum WCAG 2.1 (était 11sp → non conforme)
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.1,
        color: onSurfaceVariant,
      ),
    );
  }
}
