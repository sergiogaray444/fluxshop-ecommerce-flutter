import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  void setUser(UserModel user) {
    _user = user;
    _saveSession(user);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    if (id != null && name != null && email != null) {
      _user = UserModel(id: id, name: name, email: email);
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_user == null) return false;
    try {
      final updated = await _authService.updateUser(
        id: _user!.id,
        name: name,
        phone: phone,
        address: address,
      );
      setUser(updated);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }
}
