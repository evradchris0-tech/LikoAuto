import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_spacing.dart';
import 'package:liko_auto/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.trust,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE3EAF3),
      onSecondaryContainer: AppColors.trust,
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.successSoft,
      onTertiaryContainer: AppColors.success,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.neutral,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.background,
      surfaceContainer: AppColors.background,
      surfaceContainerHigh: AppColors.background,
      surfaceContainerHighest: Color(0xFFEBEBEB),
      outline: AppColors.outline,
      outlineVariant: Color(0xFFEEEEEE),
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AppColors.trust,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.primarySoft,
    );
    return _build(cs, AppColors.background);
  }

  static ThemeData dark() {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF6A2D14),
      onPrimaryContainer: AppColors.primarySoft,
      secondary: Color(0xFF6FA3DC),
      onSecondary: AppColors.darkBackground,
      secondaryContainer: Color(0xFF1F3A5C),
      onSecondaryContainer: Color(0xFFCFE0F4),
      tertiary: AppColors.success,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF005A40),
      onTertiaryContainer: AppColors.successSoft,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: Color(0xFF6E1A1A),
      onErrorContainer: AppColors.errorSoft,
      surface: AppColors.darkSurface,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFB8C4D2),
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: AppColors.darkBackground,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: Color(0xFF1A3553),
      surfaceContainerHighest: Color(0xFF22405F),
      outline: AppColors.darkOutline,
      outlineVariant: Color(0xFF1F3650),
      shadow: Colors.black,
      scrim: Colors.black87,
      inverseSurface: Colors.white,
      onInverseSurface: AppColors.trust,
      inversePrimary: AppColors.primary,
    );
    return _build(cs, AppColors.darkBackground);
  }

  static ThemeData _build(ColorScheme cs, Color scaffoldBg) {
    final tt = AppTypography.buildTextTheme(cs.onSurface, cs.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: tt,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: tt.headlineMedium,
        systemOverlayStyle: cs.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      // ── Buttons ────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withValues(alpha: 0.38),
          disabledForegroundColor: cs.onPrimary.withValues(alpha: 0.6),
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
          textStyle: tt.labelLarge,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.secondary,
          side: BorderSide(color: cs.outline),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
          textStyle: tt.labelMedium,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          textStyle: tt.labelMedium,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cs.surfaceContainerLowest,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rCard,
          side: BorderSide(color: cs.outline, width: 0.5),
        ),
      ),

      // ── Input ──────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 16,
        ),
        hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.rButton,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        errorStyle: tt.bodySmall?.copyWith(color: cs.error),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerLow,
        selectedColor: cs.primaryContainer,
        labelStyle: tt.labelMedium?.copyWith(color: cs.onSurface),
        side: BorderSide(color: cs.outline),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ── Navigation Bar (M3) ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tt.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return tt.labelSmall?.copyWith(color: cs.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? cs.primary
                : cs.onSurfaceVariant,
            size: 24,
          );
        }),
        height: 68,
        elevation: 0,
      ),

      // ── Popup Menu ─────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: cs.surfaceContainerLowest, // Fond clair
        textStyle: tt.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold), // Texte orange
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rCard),
        elevation: 4,
      ),

      // ── Bottom Sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerLowest, // Fond clair
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.rBottomSheet,
        ),
        elevation: 0,
        showDragHandle: false,
      ),

      // ── Dialog ─────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerLowest, // Fond clair
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rCard),
        titleTextStyle: tt.headlineSmall?.copyWith(color: cs.primary), // Texte orange
        contentTextStyle: tt.bodyMedium?.copyWith(color: cs.primary), // Texte orange
        elevation: 3,
      ),

      // ── List Tile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        titleTextStyle: tt.titleMedium,
        subtitleTextStyle: tt.bodySmall,
        iconColor: cs.onSurfaceVariant,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: cs.outline,
        thickness: 0.5,
        space: 1,
      ),

      // ── SnackBar ───────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: tt.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
        shape: const CircleBorder(),
      ),

      // ── Transitions ────────────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
