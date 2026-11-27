import 'package:flutter_test/flutter_test.dart';

import 'package:horoskopium/main.dart';

void main() {
  testWidgets('Horoskopium home screen renders', (tester) async {
    await tester.pumpWidget(HoroskopiumApp());

    expect(find.text('HOROSKOPIUM'), findsOneWidget);
    expect(find.text('Die Sprache der Sterne'), findsOneWidget);
    expect(find.text('Geburtshoroskop'), findsOneWidget);
  });
}
