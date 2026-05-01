import 'package:flutter/material.dart';

/// Palette validée — Proposition N°2, Mars 2026.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFD55D31); // Spicy Paprika
  static const Color trust = Color(0xFF0D2F50); // Deep Space Blue

  // Neutrals
  static const Color background = Color(0xFFF5F5F5); // White Smoke
  static const Color neutral = Color(0xFFA29C9F); // Rosy Granite
  static const Color surface = Colors.white;
  static const Color outline = Color(0xFFE0E0E0);

  // Semantic
  static const Color success = Color(0xFF00A676);
  static const Color error = Color(0xFFE63939);
  static const Color warning = Color(0xFFE89A2C);

  // Overlays
  static const Color primarySoft = Color(0xFFFCE7DD);
  static const Color successSoft = Color(0xFFD9F2E8);
  static const Color errorSoft = Color(0xFFFADCDC);

  // Dark mode
  static const Color darkBackground = Color(0xFF0A1828);
  static const Color darkSurface = Color(0xFF132B45);
  static const Color darkOutline = Color(0xFF26405E);
}
