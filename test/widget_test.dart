import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liko_auto/app/app.dart';

void main() {
  testWidgets('App boots and shows the showcase', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LikoAutoApp()));
    await tester.pumpAndSettle();

    expect(find.text('Design System — Liko Auto'), findsOneWidget);
  });
}
