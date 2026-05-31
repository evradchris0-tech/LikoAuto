import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension AppContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textStyles => theme.textTheme;
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isDark => theme.brightness == Brightness.dark;

  /// Navigue vers la page précédente, ou retourne à l'accueil si l'historique est vide.
  void safePop([String fallbackRoute = '/']) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackRoute);
    }
  }
}
