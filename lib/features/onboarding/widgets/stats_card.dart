import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

class StatItem {
  const StatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;
}

/// Carte stats orange (3 colonnes) utilisée dans l'onboarding.
/// Référence : "187 véhicules / 92% VIN vérifiés / 48 garages partenaires".
class StatsCard extends StatelessWidget {
  const StatsCard({required this.items, super.key});

  final List<StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: AppRadius.rCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _StatColumn(item: items[i])),
            if (i < items.length - 1)
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.25),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.item});
  final StatItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.value,
          style: context.textStyles.headlineLarge?.copyWith(
            color: item.valueColor ?? Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.label.toUpperCase(),
          textAlign: TextAlign.center,
          style: context.textStyles.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
