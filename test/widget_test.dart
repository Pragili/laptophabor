import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laptopharbor/core/utils/validators.dart';
import 'package:laptopharbor/core/utils/formatters.dart';

void main() {
  test('email validator rejects bad input, accepts good', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('not-an-email'), isNotNull);
    expect(Validators.email('ada@example.com'), isNull);
  });

  test('money formatter outputs currency', () {
    expect(money(1299), contains('1,299'));
  });

  testWidgets('a basic widget builds', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('ok'))));
    expect(find.text('ok'), findsOneWidget);
  });
}
