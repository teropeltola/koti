
import 'package:flutter_test/flutter_test.dart';
import 'package:koti/logic/service_caller.dart';
void main() {
  group('ServiceCaller', () {
/*
    late ServiceCaller serviceCaller;

    setUp(() {
      serviceCaller = ServiceCaller();
      // Clear the services map before each test
      serviceCaller.services.clear();
    });

    test('registerService adds a service to the _services map', () {
      // Define a sample service function
      void sampleService() {
        print('Sample service executed');
      }

      // Register the sample service
      serviceCaller.registerService('service1', sampleService);

      // Verify that the service was added
      expect(serviceCaller.services.containsKey('service1'), isTrue);
      expect(serviceCaller.services['service1'], equals(sampleService));
    });

    test('callAllServices calls all registered services', () async {
      // Define flags to check if services were called
      bool service1Called = false;
      bool service2Called = false;

      // Define sample service functions
      void service1() {
        service1Called = true;
      }

      void service2() {
        service2Called = true;
      }

      // Register the services
      serviceCaller.registerService('service1', service1);
      serviceCaller.registerService('service2', service2);

      // Call all services
      await serviceCaller.callAllServices();

      // Verify that both services were called
      expect(service1Called, isTrue);
      expect(service2Called, isTrue);
    });

    test('callAllServices handles async service functions', () async {
      // Define a flag to check if the async service was called
      bool asyncServiceCalled = false;

      // Define an async service function
      Future<void> asyncService() async {
        await Future.delayed(Duration(milliseconds: 100));
        asyncServiceCalled = true;
      }

      // Register the async service
      serviceCaller.registerService('asyncService', asyncService);

      // Call all services
      await serviceCaller.callAllServices();

      // Verify that the async service was called
      expect(asyncServiceCalled, isTrue);
    });


    test('ServiceCallerRegisterInConstructor', () async {
      // Define a flag to check if the async service was called
      bool asyncServiceCalled = false;

      // Define an async service function
      Future<void> asyncService() async {
        await Future.delayed(Duration(milliseconds: 100));
        asynServiceCalled = true;
      }

      // Register the async service
      ServiceCallerRegisterInConstructor s1 = ServiceCallerRegisterInConstructor(serviceCaller, 'a', asyncService);

      // Call all services
      await serviceCaller.callAllServices();

      // Verify that the async service was called
      expect(asyncServiceCalled, isTrue);
    });

 */
  });
}

