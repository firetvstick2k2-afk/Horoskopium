import 'package:flutter_test/flutter_test.dart';

import 'package:horoskopium/main.dart';

void main() {
  testWidgets('Astralium home screen renders', (tester) async {
    await tester.pumpWidget(AstraliumApp());

    expect(find.text('ASTRALIUM'), findsOneWidget);
    expect(find.text('Die Sprache der Sterne'), findsOneWidget);
    expect(find.text('Geburtshoroskop'), findsOneWidget);
  });
}
