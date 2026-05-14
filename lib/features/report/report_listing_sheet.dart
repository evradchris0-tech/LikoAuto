import 'package:flutter/material.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/home/widgets/listing_card.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';

enum ReportReason {
  vinSuspect,
  misleadingPrice,
  badPhotos,
  duplicate,
  illegal,
  scam,
  other,
}

extension on ReportReason {
  String get label {
    switch (this) {
      case ReportReason.vinSuspect:
        return 'VIN incorrect ou suspect';
      case ReportReason.misleadingPrice:
        return 'Prix trompeur';
      case ReportReason.badPhotos:
        return 'Photos non conformes ou floues';
      case ReportReason.duplicate:
        return 'Annonce en doublon';
      case ReportReason.illegal:
        return 'Contenu illégal ou interdit';
      case ReportReason.scam:
        return "Tentative d'arnaque";
      case ReportReason.other:
        return 'Autre raison';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportReason.vinSuspect:
        return Icons.qr_code_2_rounded;
      case ReportReason.misleadingPrice:
        return Icons.payments_outlined;
      case ReportReason.badPhotos:
        return Icons.image_not_supported_outlined;
      case ReportReason.duplicate:
        return Icons.content_copy_rounded;
      case ReportReason.illegal:
        return Icons.gavel_outlined;
      case ReportReason.scam:
        return Icons.warning_amber_rounded;
      case ReportReason.other:
        return Icons.more_horiz_rounded;
    }
  }
}

/// Affiche le bottom sheet de signalement. À appeler depuis VehicleDetail.
Future<void> showReportListingSheet(
  BuildContext context, {
  required ListingCardData listing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReportListingSheet(listing: listing),
  );
}

class _ReportListingSheet extends StatefulWidget {
  const _ReportListingSheet({required this.listing});

  final ListingCardData listing;

  @override
  State<_ReportListingSheet> createState() => _ReportListingSheetState();
}

class _ReportListingSheetState extends State<_ReportListingSheet> {
  ReportReason? _selected;
  final _otherCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_selected == null) return false;
    if (_selected == ReportReason.other &&
        _otherCtrl.text.trim().length < 10) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    // TODO(api): envoyer le signalement au backend NestJS.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pop(context);
    AppSnack.success(
      context,
      'Signalement reçu. Notre équipe vérifiera sous 24h.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppSpacing.gapMd,
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signaler cette annonce',
                      style: context.textStyles.headlineSmall?.copyWith(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.listing.title,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  children: [
                    for (final r in ReportReason.values)
                      _ReasonTile(
                        reason: r,
                        selected: _selected == r,
                        onTap: () => setState(() => _selected = r),
                      ),
                    if (_selected == ReportReason.other) ...[
                      AppSpacing.gapMd,
                      LikoTextField(
                        controller: _otherCtrl,
                        hintText: 'Décrivez le problème (min 10 caractères)',
                        maxLines: 4,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                    AppSpacing.gapLg,
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          AppSpacing.gapSm,
                          Expanded(
                            child: Text(
                              'Les signalements sont anonymes. Notre équipe '
                              'modération examine chaque cas sous 24h.',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: AppColors.trust,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: PrimaryButton(
                    label: 'Envoyer le signalement',
                    icon: Icons.flag_outlined,
                    isLoading: _submitting,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final ReportReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  reason.icon,
                  color: selected ? AppColors.primary : AppColors.neutral,
                  size: 22,
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Text(
                    reason.label,
                    style: TextStyle(
                      color: AppColors.trust,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(selected),
                    color: selected ? AppColors.primary : AppColors.outline,
                    size: 22,
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
