import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talyp_butjet/main.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TalyplarButjetiApp(),
      ),
    );

    expect(find.byType(TalyplarButjetiApp), findsOneWidget);
  });
}
