import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Bouton tertiaire — texte seul, sans fond.
/// Utilisé pour : Passer, Annuler, actions de moindre importance.
class TertiaryButton extends StatelessWidget {
  const TertiaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.secondary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
        textStyle: context.textStyles.labelMedium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label),
        ],
      ),
    );
  }
}
