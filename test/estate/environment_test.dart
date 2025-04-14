import 'package:flutter_test/flutter_test.dart';
import 'package:koti/devices/my_device_info.dart';
import 'package:koti/estate/environment.dart';
import 'package:koti/functionalities/functionality/functionality.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initMySettings();
  });

  group('Environment Tests 1', () {

    test('Environment test 1', () {
      Environment e = Environment();
      expect(e.name, '');
      e.name = 'test';
      expect(e.name, 'test');
      expect(e.id[0], 'e');
      expect(e.hasParent(), false);
    });
  });

  group('Environment subEnvironments', () {

    test('basic test 1', () {
      Environment parent = Environment();
      Environment child = Environment();
      parent.addSubEnvironment(child);
      expect(parent.nbrOfSubEnvironments(), 1);
      expect(child.hasParent(), true);
      expect(child.parentEnvironment, parent);
      child.removeEnvironment();
      expect(parent.nbrOfSubEnvironments(), 0);
    });
  });

  group('Environment functionalities', () {

    test('basic test 1', () {
      Environment e = Environment();
      expect(e.features.isEmpty, true);
      expect(e.views.isEmpty, true);
      expect(e.operationModes.nbrOfModes(), 0);

      expect(e.functionality('id'), allFunctionalities.noFunctionality());

      Functionality f = Functionality();
      e.addFunctionality(f);
      expect(e.features.isEmpty, false);
      expect(e.views.isEmpty, false);

      expect(e.functionality(f.id), f);

      e.removeFunctionality(f);
      expect(e.features.isEmpty, true);

    });

  });

  group('Environment json', () {

      test('basic test 1', () {
        Environment e = Environment();
        e.name = 'test';
        Environment e2 = Environment.fromJson(e.toJson());
        expect(e2.name, 'test');
        expect(e2.id, e.id );

      });

      test('basic test 2', () {
        Environment e = Environment();
        e.name = 'test';
        Environment child1 = Environment();
        child1.name = 'child1';
        e.addSubEnvironment(child1);
        Environment child2 = Environment();
        child2.name = 'child2';
        e.addSubEnvironment(child2);
        expect(child2.parentEnvironment, e);
        Environment grandchild = Environment();
        grandchild.name = 'grandchild';
        child1.addSubEnvironment(grandchild);
        Environment e2 = Environment.fromJson(e.toJson());
        expect(e2.name, 'test');
        expect(e2.id, e.id );
        expect(e2.nbrOfSubEnvironments(), 2);
        expect(e2.environments[0].name, 'child1');
        expect(e2.environments[1].name, 'child2');
        expect(e2.environments[1].parentEnvironment, e2);
        expect(e2.environments[0].environments[0].name, 'grandchild');

      });


      test('basic test 3', () {
        Environment e = Environment();
        e.name = 'test';
        Environment child1 = Environment();
        child1.name = 'child1';
        e.addSubEnvironment(child1);
        Environment child2 = Environment();
        child2.name = 'child2';
        Functionality f = Functionality();
        child2.addFunctionality(f);
        e.addSubEnvironment(child2);
        expect(child2.parentEnvironment, e);
        Environment grandchild = Environment();
        grandchild.name = 'grandchild';
        Functionality f3 = Functionality();
        grandchild.addFunctionality(f3);
        child1.addSubEnvironment(grandchild);

        var json = e.toJson();
        expect(child2.features.length, 1);
        expect(child2.views.length, 1);
        expect(grandchild.features.length, 1);
        expect(grandchild.views.length, 1);
        child2.dispose();
        grandchild.dispose();

        Environment e2 = Environment.fromJson(json);
        expect(e2.name, 'test');
        expect(e2.id, e.id );
        expect(e2.nbrOfSubEnvironments(), 2);
        expect(e2.environments[0].name, 'child1');
        expect(e2.environments[1].name, 'child2');
        expect(e2.environments[1].parentEnvironment, e2);
        expect(e2.environments[0].environments[0].name, 'grandchild');


        expect(e2.environments[1].features.length, 1);
        expect(e2.environments[1].views.length, 1);
        expect(e2.environments[0].environments[0].features.length, 1);
        expect(e2.environments[0].environments[0].views.length, 1);

      });

  });

  group('find Environment for', () {

    test('basic test 1', () {
      Environment e = Environment();
      Functionality f = Functionality();
      e.addFunctionality(f);

      Environment e2 = Environment();

      expect(e.findEnvironmentFor(f),e);
      expect(e2.findEnvironmentFor(f),noEnvironment);

      Environment child = Environment();
      e2.addSubEnvironment(child);
      expect(e2.findEnvironmentFor(f),noEnvironment);

      child.addSubEnvironment(e);
      expect(e2.findEnvironmentFor(f),e);

      Functionality f2 = Functionality();
      child.addFunctionality(f2);
      expect(e2.findEnvironmentFor(f2),child);
      expect(e2.findEnvironmentFor(f),e);

    });

  });

}
