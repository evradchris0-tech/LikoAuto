import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';

/// Helper centralisé pour les SnackBars de l'application.
///
/// Convention :
/// - `success` : action positive accomplie (publication, vente, ajout favori)
/// - `error`   : erreur ou action destructive confirmée
/// - `info`    : info neutre, retrait passif, message contextuel
/// - `warning` : avertissement non bloquant (connexion lente, mode dégradé)
///
/// Paramètre optionnel `actionLabel` + `onAction` pour un bouton "Voir" /
/// "Réessayer" / "Annuler" affiché à droite (wireframe 6.1).
abstract final class AppSnack {
  static const _floating = SnackBarBehavior.floating;
  static const _duration = Duration(seconds: 3);
  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static const _margin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.success,
      Icons.check_circle_rounded,
      actionLabel,
      onAction,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.error,
      Icons.error_outline_rounded,
      actionLabel,
      onAction,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.trust,
      Icons.info_outline_rounded,
      actionLabel,
      onAction,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      AppColors.warning,
      Icons.warning_amber_rounded,
      actionLabel,
      onAction,
    );
  }

  static void _show(
    BuildContext context,
    String message,
    Color bg,
    IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
  ) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: bg,
          behavior: _floating,
          duration: _duration,
          shape: _shape,
          margin: _margin,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
