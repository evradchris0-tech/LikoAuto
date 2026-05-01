import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liko_auto/core/theme/app_theme.dart';
import 'package:liko_auto/features/showcase/showcase_screen.dart';

/// Test smoke isolé sur le ShowcaseScreen.
/// Le SplashScreen n'est pas testé ici car il déclenche des animations
/// infinies (PulsingDots) qui empêchent pumpAndSettle de se terminer —
/// il sera couvert par des tests de widget dédiés plus tard.
void main() {
  testWidgets('Design System showcase renders', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const ShowcaseScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Design System — Liko Auto'), findsOneWidget);
  });
}
