import 'package:flutter_test/flutter_test.dart';

import 'package:unilib/main.dart';

void main() {
  testWidgets('App abre na tela de Login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Entrar'), findsOneWidget);
  });
}
