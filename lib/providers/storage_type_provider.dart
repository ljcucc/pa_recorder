import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageType {
  sqlite,
  fileSystem,
}

class StorageTypeProvider with ChangeNotifier {
  static const String _storageTypeKey = 'storage_type';
  StorageType _currentStorageType = StorageType.fileSystem; // Default to FileSystem

  StorageTypeProvider() {
    _loadStorageType();
  }

  StorageType get currentStorageType => _currentStorageType;

  Future<void> _loadStorageType() async {
    final prefs = await SharedPreferences.getInstance();
    final storedType = prefs.getString(_storageTypeKey);
    if (storedType == 'sqlite') {
      _currentStorageType = StorageType.sqlite;
    } else {
      _currentStorageType = StorageType.fileSystem; // Default if not set or invalid
    }
    notifyListeners();
  }

  Future<void> setStorageType(StorageType type) async {
    final prefs = await SharedPreferences.getInstance();
    _currentStorageType = type;
    await prefs.setString(_storageTypeKey, type == StorageType.sqlite ? 'sqlite' : 'filesystem');
    notifyListeners();
  }
}
