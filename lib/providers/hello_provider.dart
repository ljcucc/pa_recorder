import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HelloProvider extends ChangeNotifier {
  bool _hasHello = false;
  final Completer<void> _completer = Completer<void>();

  bool get hasHello => _hasHello;
  Future<void> get initialized => _completer.future;

  HelloProvider() {
    _loadHasHello();
  }

  Future<void> _loadHasHello() async {
    final prefs = await SharedPreferences.getInstance();
    _hasHello = prefs.getBool('has_hello') ?? false;
    notifyListeners();
    _completer.complete();
  }

  Future<void> setHasHello(bool value) async {
    _hasHello = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_hello', value);
    notifyListeners();
  }
}
