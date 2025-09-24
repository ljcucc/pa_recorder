import 'package:flutter_test/flutter_test.dart';
import 'package:pa_recorder/providers/hello_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HelloProvider', () {
    setUp(() {
      // Reset SharedPreferences mock before each test
      SharedPreferences.setMockInitialValues({}); 
    });

    test('hasHello should be false by default if no value is stored', () async {
      final helloProvider = HelloProvider();
      await helloProvider.initialized; // Wait for _loadHasHello to complete
      expect(helloProvider.hasHello, false);
    });

    test('hasHello should load true if value is stored as true', () async {
      SharedPreferences.setMockInitialValues({'has_hello': true});
      final helloProvider = HelloProvider();
      await helloProvider.initialized; // Wait for _loadHasHello to complete
      expect(helloProvider.hasHello, true);
    });

    test('setHasHello should update value and notify listeners', () async {
      final helloProvider = HelloProvider();
      await helloProvider.initialized; // Ensure initial load is complete

      var listenerCalled = false;
      helloProvider.addListener(() {
        listenerCalled = true;
      });

      await helloProvider.setHasHello(true);

      expect(helloProvider.hasHello, true);
      expect(listenerCalled, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_hello'), true);
    });

    test('setHasHello should update value to false and notify listeners', () async {
      SharedPreferences.setMockInitialValues({'has_hello': true});
      final helloProvider = HelloProvider();
      await helloProvider.initialized; // Ensure initial load is complete

      var listenerCalled = false;
      helloProvider.addListener(() {
        listenerCalled = true;
      });

      await helloProvider.setHasHello(false);

      expect(helloProvider.hasHello, false);
      expect(listenerCalled, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_hello'), false);
    });
  });
}
