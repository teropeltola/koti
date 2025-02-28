import 'package:flutter_test/flutter_test.dart';
import 'package:koti/estate/environment.dart';


void main() {
  group('Environment Tests 1', () {

    setUp(() {
    });

    test('Environment test 1', () {
      Environment e = Environment();
      expect(e.name, '');
    });


  });
}
