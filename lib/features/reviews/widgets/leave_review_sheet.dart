import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/reviews/domain/review.dart';
import 'package:liko_auto/features/reviews/providers/reviews_provider.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Affiche un modal "Instagram" pour laisser un avis sur une cible (garage,
/// véhicule, vendeur, acheteur).
///
/// - Plein écran 95% par défaut, drag handle, coins arrondis
/// - `verified` = true si l'avis suit une transaction/RDV confirmé
Future<void> showLeaveReviewSheet(
  BuildContext context, {
  required ReviewTargetType targetType,
  required String targetId,
  required String targetName,
  required bool verified,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _LeaveReviewSheet(
      targetType: targetType,
      targetId: targetId,
      targetName: targetName,
      verified: verified,
    ),
  );
}

class _LeaveReviewSheet extends ConsumerStatefulWidget {
  const _LeaveReviewSheet({
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.verified,
  });

  final ReviewTargetType targetType;
  final String targetId;
  final String targetName;
  final bool verified;

  @override
  ConsumerState<_LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends ConsumerState<_LeaveReviewSheet> {
  double _rating = 0;
  final _selectedTags = <String>{};
  final _bodyCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _bodyCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit => _rating > 0;

  String get _ratingHint {
    if (_rating == 0) return 'Touchez les étoiles pour noter';
    if (_rating <= 2) return 'Décevant';
    if (_rating <= 3) return 'Correct';
    if (_rating <= 4) return 'Très bien';
    return 'Excellent !';
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final review = Review(
      id: 'R-${DateTime.now().millisecondsSinceEpoch}',
      targetType: widget.targetType,
      targetId: widget.targetId,
      authorName: 'Vous',
      rating: _rating,
      body: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
      tags: _selectedTags.toList(),
      verified: widget.verified,
      createdAt: DateTime.now(),
    );
    await ref.read(reviewsActionsProvider).publish(review);
    if (!mounted) return;
    Navigator.pop(context);
    AppSnack.success(context, 'Merci pour votre avis !');
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _Header(
                  targetName: widget.targetName,
                  onClose: () => Navigator.pop(context),
                ),
                const Divider(height: 1, color: AppColors.outline),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Center(
                        child: Text(
                          _ratingHint,
                          style: context.textStyles.titleMedium?.copyWith(
                            color: AppColors.trust,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      AppSpacing.gapLg,
                      _StarRating(
                        rating: _rating,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      AppSpacing.gapXl,
                      Text(
                        'Mots-clés (optionnel)',
                        style: context.textStyles.labelLarge?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.gapSm,
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tag in reviewSuggestedTags)
                            _TagChip(
                              label: tag,
                              selected: _selectedTags.contains(tag),
                              onTap: () => setState(() {
                                if (_selectedTags.contains(tag)) {
                                  _selectedTags.remove(tag);
                                } else {
                                  if (_selectedTags.length < 3) {
                                    _selectedTags.add(tag);
                                  } else {
                                    AppSnack.warning(
                                      context,
                                      '3 mots-clés max.',
                                    );
                                  }
                                }
                              }),
                            ),
                        ],
                      ),
                      AppSpacing.gapXl,
                      Text(
                        'Votre commentaire (optionnel)',
                        style: context.textStyles.labelLarge?.copyWith(
                          color: AppColors.trust,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      AppSpacing.gapSm,
                      TextField(
                        controller: _bodyCtrl,
                        maxLines: 5,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText:
                              'Partagez votre expérience pour aider les autres…',
                          hintStyle: const TextStyle(color: AppColors.neutral),
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      if (widget.verified) ...[
                        AppSpacing.gapMd,
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.badgeCheck,
                                color: AppColors.success,
                                size: 18,
                              ),
                              AppSpacing.gapSm,
                              Expanded(
                                child: Text(
                                  'Votre avis sera marqué « Vérifié » : '
                                  'il fait suite à une transaction.',
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: PrimaryButton(
                      label: 'Publier mon avis',
                      icon: LucideIcons.send,
                      isLoading: _submitting,
                      onPressed: _canSubmit ? _submit : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.targetName, required this.onClose});

  final String targetName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laisser un avis',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'pour $targetName',
                  style: const TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.trust),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onChanged});

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () => onChanged(i.toDouble()),
              customBorder: const CircleBorder(),
              child: AnimatedScale(
                scale: rating >= i ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    rating >= i ? LucideIcons.star : LucideIcons.star,
                    size: 48,
                    color: rating >= i
                        ? AppColors.primary
                        : AppColors.neutral.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.background,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.trust,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
