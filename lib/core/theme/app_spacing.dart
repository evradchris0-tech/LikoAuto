import 'package:flutter/widgets.dart';

/// Échelle d'espacement — multiples de 4dp.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Gaps universels (Column ET Row) ───────────────────────────────────────
  static const SizedBox gapXxs = SizedBox(width: xxs, height: xxs);
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
  static const SizedBox gapXxxl = SizedBox(width: xxxl, height: xxxl);

  // ── Paddings communs ───────────────────────────────────────────────────────
  /// Marges latérales des pages — 20dp (confortable sur grands écrans 6"+).
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: lg,
  );

  /// Padding interne des cartes — 16dp standard Material.
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Padding de section (titres de section + liste horizontale).
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: sm,
  );
}
