import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Bouton d'action principal — hérite du `elevatedButtonTheme`.
/// Gère uniquement ce que le thème ne peut pas exprimer :
/// - l'état de chargement (spinner + fond primary maintenu)
/// - l'option full-width
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      // Override uniquement pour le loading : garder la couleur primaire
      // même quand onPressed est null (état visuellement "actif mais occupé").
      style: isLoading
          ? ElevatedButton.styleFrom(
              disabledBackgroundColor: cs.primary,
              disabledForegroundColor: cs.onPrimary,
            )
          : null, // hérite entièrement du elevatedButtonTheme
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
