import 'package:flutter_test/flutter_test.dart';
import 'package:makeme/app.dart';

void main()
{
  testWidgets('App starts with LoginScreen', (tester) async
  {
    await tester.pumpWidget(const MakeMeApp());
    expect(find.text('Login Screen'), findsOneWidget);
  });
}