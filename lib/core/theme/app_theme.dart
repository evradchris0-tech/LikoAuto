import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liko_auto/core/theme/app_colors.dart';
import 'package:liko_auto/core/theme/app_radius.dart';
import 'package:liko_auto/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
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
      onSurface: AppColors.trust,
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

    return _build(colorScheme, AppColors.background);
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
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

    return _build(colorScheme, AppColors.darkBackground);
  }

  static ThemeData _build(ColorScheme cs, Color scaffoldBg) {
    final textTheme = AppTypography.buildTextTheme(
      cs.onSurface,
      cs.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: cs.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainerLowest,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rCard),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
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
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.all(textTheme.labelSmall),
        height: 72,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      dividerTheme: DividerThemeData(color: cs.outline, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.rButton),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
