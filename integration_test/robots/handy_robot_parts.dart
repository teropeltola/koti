import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future <void> selectDropdownItem(WidgetTester tester, String keyString, String selectionText) async {

  await tester.pumpAndSettle();

  final Finder dropdownForm = find.byKey(Key(keyString));

  expect(dropdownForm, findsOneWidget);

  // Enter selection text
  await tester.tap(dropdownForm);
  await tester.pumpAndSettle();
  await tester.tap(find.text(selectionText).last);
  await tester.pumpAndSettle();
}

Future <void> enterTextField(WidgetTester tester, String key, String newText) async {

  await tester.scrollUntilVisible(
      find.byKey(Key(key)), 500.0, scrollable: find.byType(Scrollable).last);

  final Finder textForm = find.byKey(Key(key));

  expect(textForm, findsOneWidget);

  // Enter selection text
  await tester.tap(textForm);
  await tester.pumpAndSettle();
  await tester.enterText(textForm, newText);
  await tester.pumpAndSettle();
}

Future <void> tapReadyButton(WidgetTester tester) async {
  await tapTextContaining(tester, 'Valmis');
}

Future <void> tapTextContaining(WidgetTester tester, String text) async {
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
      find.text(text), 500.0, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining(text));
  await tester.pumpAndSettle();
}

Future <void> tapKey(WidgetTester tester, String keyText) async {
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
      find.byKey(Key(keyText)), 500.0, scrollable: find.byType(Scrollable).last);
  final Finder textForm = find.byKey(Key(keyText));
  await tester.tap(textForm);
  await tester.pumpAndSettle();
}

Future <void> tapIcon(WidgetTester tester, IconData iconData) async {
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
      find.byIcon(iconData), 500.0, scrollable: find.byType(Scrollable).last);
  final Finder icon = find.byIcon(iconData);
  await tester.tap(icon);
  await tester.pumpAndSettle();
}

Future <void> toGetScreenUpdatesDone() async {
  await Future.delayed(const Duration(seconds: 8));
}


