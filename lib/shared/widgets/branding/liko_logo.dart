import 'package:flutter/material.dart';
import 'package:liko_auto/core/constants/app_assets.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Logo Liko Auto — bouclier + check + wordmark.
/// Source : assets/images/liko_logo.jpeg (fond Spicy Paprika).
class LikoLogo extends StatelessWidget {
  const LikoLogo({this.size = 48, this.rounded = true, super.key});

  /// Variante carrée arrondie pour app bar / splash.
  const LikoLogo.app({super.key}) : size = 40, rounded = true;

  /// Variante grande pour splash.
  const LikoLogo.large({super.key}) : size = 120, rounded = true;

  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.logo,
      width: size,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: 'Logo Liko Auto',
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        color: AppColors.primary,
        child: const Icon(Icons.shield, color: Colors.white),
      ),
    );

    if (!rounded) return image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: image,
    );
  }
}
