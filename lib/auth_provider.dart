import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    // Perform login logic here
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    // Perform logout logic here
    _isLoggedIn = false;
    notifyListeners();
  }
}
