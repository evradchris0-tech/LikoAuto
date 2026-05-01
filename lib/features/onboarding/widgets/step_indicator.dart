import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';

/// "ÉTAPE 1 SUR 4" — texte caps orange utilisé en haut des pages onboarding.
class StepIndicator extends StatelessWidget {
  const StepIndicator({required this.current, required this.total, super.key});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Text(
      'ÉTAPE $current SUR $total',
      style: context.textStyles.labelMedium?.copyWith(
        color: context.colors.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}
