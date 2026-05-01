import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';

/// Écran placeholder pour les onglets dont l'UI n'est pas encore construite
/// (Vendre, Chat, Profil). À remplacer dans les sprints suivants.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.subtitle,
    super.key,
  });

  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 44, color: AppColors.primary),
                ),
                AppSpacing.gapLg,
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textStyles.headlineLarge?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.gapSm,
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium,
                ),
                AppSpacing.gapMd,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'En construction · Sprint à venir',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
