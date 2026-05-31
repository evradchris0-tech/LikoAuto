import 'package:flutter/material.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:lucide_icons/lucide_icons.dart';

abstract final class AppSnack {
  static const _duration = Duration(seconds: 3);
  static const _shape = RoundedRectangleBorder(borderRadius: AppRadius.rButton);
  static const _margin = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.sm,
  );

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    AppColors.success,
    LucideIcons.checkCircle,
    actionLabel,
    onAction,
  );

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    AppColors.error,
    LucideIcons.alertCircle,
    actionLabel,
    onAction,
  );

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    AppColors.info,
    LucideIcons.info,
    actionLabel,
    onAction,
  );

  static void warning(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    AppColors.warning,
    LucideIcons.alertTriangle,
    actionLabel,
    onAction,
  );

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
          behavior: SnackBarBehavior.floating,
          duration: _duration,
          shape: _shape,
          margin: _margin,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
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
