import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class DirectoryProvider with ChangeNotifier {
  String? _directoryPath;

  String? get directoryPath => _directoryPath;

  Future<void> selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      _directoryPath = selectedDirectory;
      notifyListeners();
    }
  }
}
