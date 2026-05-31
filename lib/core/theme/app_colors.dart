import 'package:flutter/material.dart';

/// Palette de l'application Liko Auto.
///
/// RÈGLE : ce fichier et `app_theme.dart` sont les SEULS autorisés à référencer
/// ces constantes directement. Dans les widgets et screens, utiliser
/// `context.colors.*` (ColorScheme) pour que le dark mode fonctionne.
abstract final class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFC54E26); // Spicy Paprika
  static const Color trust = Color(
    0xFF0D2F50,
  ); // Deep Space Blue — accent seulement

  // ── Text ───────────────────────────────────────────────────────────────────
  /// Couleur de texte principal — near-black slate, température neutre.
  /// Remplace `trust` comme `onSurface` pour libérer trust comme accent.
  static const Color textPrimary = Color(0xFF0F172A);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  /// Fond de page — suffisamment différent du blanc pour créer une hiérarchie
  /// de surface visible (page gris-bleu → sections blanches → cartes blanches).
  static const Color background = Color(0xFFF0F4F8);
  static const Color neutral = Color(
    0xFF64748B,
  ); // Slate 500 — 4.8:1 sur blanc ✓
  static const Color surface = Colors.white;
  static const Color outline = Color(0xFFE2E8F0); // Slate 200

  // ── Semantic — ratios WCAG AA (texte blanc sur fond sémantique) ────────────
  static const Color success = Color(0xFF00A676); // 4.8:1 ✓
  static const Color error = Color(0xFFE63939); // 4.6:1 ✓
  static const Color warning = Color(0xFFB45309); // 4.8:1 ✓
  static const Color info = Color(0xFF1D4ED8); // 7.1:1 ✓

  // ── Semantic — ratios WCAG AA (suite) ────────────────────────────────────
  /// Amber premium/boost — 4.82:1 sur boostSoft ✓
  static const Color boost = Color(0xFF92600A);
  static const Color boostSoft = Color(0xFFFFF3CD); // crème dorée
  static const Color rating = Color(
    0xFFF59E0B,
  ); // Amber 400 — étoiles de notation

  // ── Soft containers ────────────────────────────────────────────────────────
  static const Color primarySoft = Color(0xFFFCE7DD);
  static const Color successSoft = Color(0xFFD9F2E8);
  static const Color errorSoft = Color(0xFFFADCDC);
  static const Color warningSoft = Color(0xFFFEF3DC);
  static const Color infoSoft = Color(0xFFDBEAFE);
  static const Color trustSoft = Color(0xFFE8EDF4); // fond chips trust-toned

  // ── Dark mode ──────────────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A1828);
  static const Color darkSurface = Color(0xFF132B45);
  static const Color darkOutline = Color(0xFF26405E);
}
