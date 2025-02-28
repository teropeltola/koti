import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';


// Generate mocks for dependencies
@GenerateMocks([FlutterSecureStorage])
void main() {
  /*
  group('WebLoginData', () {
    late WebLoginData webLoginData;
    late MockFlutterSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockFlutterSecureStorage();
      webLoginData = WebLoginData();
      // Inject the mock secure storage
      webLoginData.initMock(mockSecureStorage);
    });

    test('initial values are correct', () {
      expect(webLoginData.url, '');
    });

    test('init sets id and url', () {
      expect(webLoginData.url, 'https://test.url');
    });

    test('username returns stored username', () async {
      when(mockSecureStorage.read(key: 'testIdusername')).thenAnswer((_) async => 'testUser');

      final username = await webLoginData.username();

      expect(username, 'testUser');
    });

    test('password returns stored password', () async {
      when(mockSecureStorage.read(key: 'testIdpassword')).thenAnswer((_) async => 'testPass');

      final password = await webLoginData.password();

      expect(password, 'testPass');
    });

    test('initUsernameAndPassword stores username and password', () async {
      await webLoginData.initUsernameAndPassword('testUser', 'testPass');

      verify(mockSecureStorage.write(key: 'testIdusername', value: 'testUser')).called(1);
      verify(mockSecureStorage.write(key: 'testIdpassword', value: 'testPass')).called(1);
    });

    test('deletePermanentData deletes stored username and password and resets id and url', () async {
      await webLoginData.deletePermanentData();

      verify(mockSecureStorage.delete(key: 'testIdusername')).called(1);
      verify(mockSecureStorage.delete(key: 'testIdpassword')).called(1);
      expect(webLoginData.url, '');
    });
  });

   */
}
