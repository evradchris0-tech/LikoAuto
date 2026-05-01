import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_radius.dart';

/// Bouton d'action principal — radius 12, hauteur 56, fond primary.
/// Utilisé pour : Publier, Contacter, Vendre, Confirmer.
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
    final isDisabled = onPressed == null || isLoading;

    final button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: cs.primary.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
        textStyle: context.textStyles.labelLarge,
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
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
                  const SizedBox(width: 8),
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
