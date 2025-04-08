import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  UserProvider() {
    loadUserFromPrefs();
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final userToken = prefs.getString('token');

    if (userData != null && userToken != null) {
      _user = jsonDecode(userData);
      _token = userToken;
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
    await prefs.setString('token', token);

    _user = userData;
    _token = token;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('token');

    _user = null;
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    if (_user != null) {
      _user!.addAll(updatedData);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));
      notifyListeners();
    }
  }
}

