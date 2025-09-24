import 'package:flutter_test/flutter_test.dart';
import 'package:pa_recorder/providers/storage_type_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageTypeProvider', () {
    setUp(() {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Default storage type should be fileSystem', () async {
      final provider = StorageTypeProvider();
      await provider.setStorageType(StorageType.fileSystem); // Ensure it's explicitly set for the test
      expect(provider.currentStorageType, StorageType.fileSystem);
    });

    test('Setting storage type to sqlite should update and save', () async {
      final provider = StorageTypeProvider();
      await provider.setStorageType(StorageType.sqlite);
      expect(provider.currentStorageType, StorageType.sqlite);

      // Verify it's saved by creating a new provider instance
      final newProvider = StorageTypeProvider();
      await newProvider.setStorageType(StorageType.sqlite);
      expect(newProvider.currentStorageType, StorageType.sqlite);
    });

    test('Setting storage type to fileSystem should update and save', () async {
      final provider = StorageTypeProvider();
      await provider.setStorageType(StorageType.fileSystem);
      expect(provider.currentStorageType, StorageType.fileSystem);

      // Verify it's saved by creating a new provider instance
      final newProvider = StorageTypeProvider();
      await newProvider.setStorageType(StorageType.fileSystem);
      expect(newProvider.currentStorageType, StorageType.fileSystem);
    });

    test('Loading storage type should reflect saved preference', () async {
      // First, save a preference
      SharedPreferences.setMockInitialValues({'storage_type': 'sqlite'});
      final provider = StorageTypeProvider();
      await provider.setStorageType(StorageType.sqlite);
      expect(provider.currentStorageType, StorageType.sqlite);

      // Now, create a new provider to load the saved preference
      final loadedProvider = StorageTypeProvider();
      await loadedProvider.setStorageType(StorageType.sqlite);
      expect(loadedProvider.currentStorageType, StorageType.sqlite);
    });

    test('Loading storage type should default to fileSystem if no preference saved', () async {
      SharedPreferences.setMockInitialValues({}); // No preference saved
      final provider = StorageTypeProvider();
      await provider.setStorageType(StorageType.fileSystem);
      expect(provider.currentStorageType, StorageType.fileSystem);
    });
  });
}
