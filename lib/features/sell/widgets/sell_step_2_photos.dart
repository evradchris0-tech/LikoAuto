import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/sell/providers/sell_form_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SellStep2Photos extends ConsumerWidget {
  const SellStep2Photos({super.key});

  static const int _minPhotos = 5;
  static const int _maxPhotos = 21;

  Future<void> _pick(WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(limit: _maxPhotos);
    if (picked.isEmpty) return;
    final files = picked.map((x) => File(x.path)).toList();
    ref.read(sellFormProvider.notifier).addPhotos(files);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(sellFormProvider).photos;
    final remaining = _minPhotos - photos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Photos du véhicule',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        AppSpacing.gapMd,
        Text(
          'Minimum $_minPhotos photos. La 1ère sera la photo principale. (max $_maxPhotos)',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.neutral,
          ),
        ),
        AppSpacing.gapXl,
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: photos.length >= _maxPhotos ? null : () => _pick(ref),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  AppSpacing.gapMd,
                  Text(
                    photos.length >= _maxPhotos
                        ? 'Limite atteinte ($_maxPhotos)'
                        : 'Ajouter des photos',
                    style: context.textStyles.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.gapMd,
        _PhotosCounter(count: photos.length, remaining: remaining),
        AppSpacing.gapLg,
        if (photos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(photos[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: () => ref
                            .read(sellFormProvider.notifier)
                            .removePhotoAt(index),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Principale',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _PhotosCounter extends StatelessWidget {
  const _PhotosCounter({required this.count, required this.remaining});

  final int count;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    if (remaining <= 0) {
      return Row(
        children: [
          const Icon(
            LucideIcons.badgeCheck,
            color: AppColors.success,
            size: 16,
          ),
          AppSpacing.gapXs,
          Text(
            '$count photos sélectionnées — minimum atteint.',
            style: context.textStyles.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    return Text(
      'Encore $remaining photo${remaining > 1 ? "s" : ""} pour atteindre le minimum.',
      style: context.textStyles.labelMedium?.copyWith(
        color: AppColors.neutral,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
