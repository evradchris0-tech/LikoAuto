import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liko_auto/app/router.dart';
import 'package:liko_auto/core/extensions/context_extensions.dart';
import 'package:liko_auto/core/extensions/number_formatting.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/features/bookings/domain/booking.dart';
import 'package:liko_auto/features/bookings/providers/bookings_provider.dart';
import 'package:liko_auto/features/garage_detail/domain/garage_detail.dart';
import 'package:liko_auto/features/garage_detail/providers/garage_detail_provider.dart';
import 'package:liko_auto/features/notifications_inbox/domain/app_notification.dart';
import 'package:liko_auto/features/notifications_inbox/providers/notifications_inbox_provider.dart';
import 'package:liko_auto/features/search/widgets/garage_result_card.dart';
import 'package:liko_auto/shared/widgets/buttons/primary_button.dart';
import 'package:liko_auto/shared/widgets/feedback/app_snack.dart';
import 'package:liko_auto/shared/widgets/inputs/liko_text_field.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookingFlowArgs {
  const BookingFlowArgs({required this.garage});
  final GarageCardData garage;
}

class BookingFlowScreen extends ConsumerStatefulWidget {
  const BookingFlowScreen({required this.args, super.key});
  final BookingFlowArgs args;

  @override
  ConsumerState<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends ConsumerState<BookingFlowScreen> {
  int _step = 0;
  GarageService? _service;
  DateTime? _date;
  int? _slotMinutes; // minutes since midnight
  final _noteCtrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_step == 0) return _service != null;
    if (_step == 1) return _date != null && _slotMinutes != null;
    return true;
  }

  Future<void> _confirm() async {
    if (_service == null || _date == null || _slotMinutes == null) return;
    setState(() => _submitting = true);
    final scheduledAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _slotMinutes! ~/ 60,
      _slotMinutes! % 60,
    );
    final booking = Booking.fromGarage(
      id: 'B-${DateTime.now().millisecondsSinceEpoch}',
      garage: widget.args.garage,
      service: _service!,
      scheduledAt: scheduledAt,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    await ref.read(bookingsActionsProvider)?.create(booking);
    // Push une notification de confirmation
    final fmt = DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR');
    await ref
        .read(notificationsActionsProvider)
        ?.push(
          AppNotification(
            id: 'N-${booking.id}',
            type: NotifType.appointment,
            title: 'RDV confirmé',
            body:
                '${widget.args.garage.name} — ${_service!.label}, ${fmt.format(scheduledAt)}.',
            createdAt: DateTime.now(),
            payload: const {'route': '/my_bookings'},
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    AppSnack.success(context, 'Rendez-vous confirmé !');
    context.go(AppRoutes.myBookings);
  }

  @override
  Widget build(BuildContext context) {
    final garage = widget.args.garage;
    final detail = ref.watch(garageDetailProvider(garage));

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_step > 0) {
          setState(() => _step--);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.x, color: AppColors.trust),
            onPressed: () {
              if (_step > 0) {
                setState(() => _step--);
              } else {
                context.safePop();
              }
            },
          ),
          title: Text(
            'Prendre un RDV',
            style: context.textStyles.headlineSmall?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              backgroundColor: AppColors.outline.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
        ),
        body: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GarageHeader(garage: garage),
                AppSpacing.gapLg,
                Text(
                  'Étape ${_step + 1} sur 3',
                  style: context.textStyles.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.gapSm,
                if (_step == 0)
                  _StepService(
                    services: detail.services,
                    selected: _service,
                    onSelect: (s) => setState(() => _service = s),
                  )
                else if (_step == 1)
                  _StepDateSlot(
                    date: _date,
                    slotMinutes: _slotMinutes,
                    durationMin: _service!.durationMin,
                    onDateChanged: (d) => setState(() {
                      _date = d;
                      _slotMinutes = null;
                    }),
                    onSlotChanged: (m) => setState(() => _slotMinutes = m),
                  )
                else
                  _StepSummary(
                    garage: garage,
                    service: _service!,
                    scheduledAt: DateTime(
                      _date!.year,
                      _date!.month,
                      _date!.day,
                      _slotMinutes! ~/ 60,
                      _slotMinutes! % 60,
                    ),
                    noteCtrl: _noteCtrl,
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                if (_step > 0) ...[
                  OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.trust,
                    ),
                  ),
                  AppSpacing.gapMd,
                ],
                Expanded(
                  child: PrimaryButton(
                    label: _step == 2 ? 'Confirmer le RDV' : 'Continuer',
                    icon: _step == 2
                        ? LucideIcons.calendarCheck
                        : LucideIcons.arrowRight,
                    isLoading: _submitting,
                    onPressed: _canContinue
                        ? () {
                            if (_step < 2) {
                              setState(() => _step++);
                            } else {
                              _confirm();
                            }
                          }
                        : null,
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

class _GarageHeader extends StatelessWidget {
  const _GarageHeader({required this.garage});
  final GarageCardData garage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: ColoredBox(
                color: AppColors.primarySoft,
                child: Image.asset(garage.imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garage.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.trust,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  garage.location,
                  style: const TextStyle(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1 : Service ───────────────────────────────────────────────────────

class _StepService extends StatelessWidget {
  const _StepService({
    required this.services,
    required this.selected,
    required this.onSelect,
  });

  final List<GarageService> services;
  final GarageService? selected;
  final ValueChanged<GarageService> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quel service ?',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          'Choisissez la prestation que vous souhaitez réserver.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.neutral,
          ),
        ),
        AppSpacing.gapLg,
        for (final s in services)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ServiceTile(
              service: s,
              selected: selected?.label == s.label,
              onTap: () => onSelect(s),
            ),
          ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final GarageService service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
                LucideIcons.wrench,
                color: selected ? AppColors.primary : AppColors.neutral,
                size: 24,
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.label,
                      style: const TextStyle(
                        color: AppColors.trust,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '~ ${service.durationMin} min',
                      style: const TextStyle(
                        color: AppColors.neutral,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'dès ${service.priceFromFcfa.toFcfa()}',
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.trust,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 2 : Date + créneau ────────────────────────────────────────────────

class _StepDateSlot extends StatelessWidget {
  const _StepDateSlot({
    required this.date,
    required this.slotMinutes,
    required this.durationMin,
    required this.onDateChanged,
    required this.onSlotChanged,
  });

  final DateTime? date;
  final int? slotMinutes;
  final int durationMin;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<int> onSlotChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 60));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quand ?',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        AppSpacing.gapSm,
        Text(
          'Sélectionnez une date puis un créneau disponible.',
          style: context.textStyles.bodyMedium?.copyWith(
            color: AppColors.neutral,
          ),
        ),
        AppSpacing.gapLg,
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(onSurface: AppColors.trust),
            ),
            child: CalendarDatePicker(
              initialDate: date ?? firstDate,
              firstDate: firstDate,
              lastDate: lastDate,
              onDateChanged: onDateChanged,
              selectableDayPredicate: (d) => d.weekday != DateTime.sunday,
            ),
          ),
        ),
        if (date != null) ...[
          AppSpacing.gapLg,
          Text(
            'Créneaux disponibles',
            style: context.textStyles.labelLarge?.copyWith(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
          AppSpacing.gapSm,
          _SlotsGrid(
            durationMin: durationMin,
            day: date!,
            selected: slotMinutes,
            onSelect: onSlotChanged,
          ),
        ],
      ],
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid({
    required this.durationMin,
    required this.day,
    required this.selected,
    required this.onSelect,
  });

  final int durationMin;
  final DateTime day;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    // Crée des créneaux de 30 ou 60 minutes selon la durée du service.
    final step = durationMin <= 45 ? 30 : 60;
    final isSaturday = day.weekday == DateTime.saturday;
    const start = 8 * 60; // 08:00
    final end = isSaturday ? 14 * 60 : 18 * 60;
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final nowMinutes = now.hour * 60 + now.minute;

    final slots = <int>[];
    for (var m = start; m <= end - durationMin; m += step) {
      slots.add(m);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in slots)
          _SlotChip(
            minutes: m,
            selected: selected == m,
            disabled: isToday && m <= nowMinutes,
            onTap: () => onSelect(m),
          ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.minutes,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final label =
        '${h.toString().padLeft(2, '0')}h'
        '${m.toString().padLeft(2, '0')}';
    final Color bg;
    final Color fg;
    final Color borderColor;
    if (disabled) {
      bg = AppColors.outline;
      fg = AppColors.neutral;
      borderColor = AppColors.outline;
    } else if (selected) {
      bg = AppColors.primary;
      fg = Colors.white;
      borderColor = AppColors.primary;
    } else {
      bg = Colors.white;
      fg = AppColors.trust;
      borderColor = AppColors.outline;
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 3 : Récap ─────────────────────────────────────────────────────────

class _StepSummary extends StatelessWidget {
  const _StepSummary({
    required this.garage,
    required this.service,
    required this.scheduledAt,
    required this.noteCtrl,
  });

  final GarageCardData garage;
  final GarageService service;
  final DateTime scheduledAt;
  final TextEditingController noteCtrl;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("EEEE d MMMM 'à' HH'h'mm", 'fr_FR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Vérifiez et confirmez',
          style: context.textStyles.displaySmall?.copyWith(
            color: AppColors.trust,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        AppSpacing.gapLg,
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SummaryRow(
                icon: LucideIcons.wrench,
                label: 'Service',
                value: service.label,
              ),
              const Divider(height: 24),
              _SummaryRow(
                icon: LucideIcons.calendar,
                label: 'Date',
                value: fmt.format(scheduledAt),
              ),
              const Divider(height: 24),
              _SummaryRow(
                icon: LucideIcons.timer,
                label: 'Durée estimée',
                value: '${service.durationMin} min',
              ),
              const Divider(height: 24),
              _SummaryRow(
                icon: LucideIcons.banknote,
                label: 'Prix dès',
                value: service.priceFromFcfa.toFcfa(),
              ),
            ],
          ),
        ),
        AppSpacing.gapLg,
        LikoTextField(
          controller: noteCtrl,
          hintText: 'Note pour le garage (optionnel)',
          maxLines: 3,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        AppSpacing.gapMd,
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.trust,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
