import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Carte de base de l'application — fond surface, ombre légère, radius 16.
/// Wrappe correctement les interactions tactiles avec InkWell + Semantics.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;

    final content = Material(
      color: cs.surfaceContainerLowest,
      borderRadius: AppRadius.rCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rCard,
        child: Padding(padding: padding, child: child),
      ),
    );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.rCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: AppRadius.rCard, child: content),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }
    return card;
  }
}
