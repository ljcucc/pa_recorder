import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class DirectoryProvider with ChangeNotifier {
  static const String _directoryPathKey = 'last_directory_path';

  String? _directoryPath;

  String? get directoryPath => _directoryPath;

  DirectoryProvider() {
    _loadDirectoryPath();
  }

  Future<void> _loadDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    _directoryPath = prefs.getString(_directoryPathKey);
    notifyListeners();
  }

  Future<void> selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      _directoryPath = selectedDirectory;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_directoryPathKey, selectedDirectory);
      notifyListeners();
    }
  }
}
