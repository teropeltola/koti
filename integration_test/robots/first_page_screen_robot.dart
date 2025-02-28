import 'package:flutter_test/flutter_test.dart';

class FirstPageScreenRobot {

  static String readyText = 'Määrittele hallittava kohde';

  const FirstPageScreenRobot(this.tester);

  final WidgetTester tester;

  Future <void> validate() async {
    expect(find.textContaining('Tervetuloa käyttämään'),findsOneWidget);
    expect(find.text(readyText),findsOneWidget);
  }

  Future <void> tapNextScreen() async {
    await tester.pumpAndSettle();
    //todo: scroll until visible?
    await tester.tap(find.textContaining(readyText));
    await tester.pumpAndSettle();
  }

}