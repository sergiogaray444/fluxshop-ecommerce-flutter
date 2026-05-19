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
    notifyListeners();
  }

  Future<void> saveSession(UserModel user, String accessToken, String refreshToken) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_apellidos', user.apellidos);
    await prefs.setString('user_username', user.username);
    await prefs.setString('user_email', user.email);
    if (user.phone != null) await prefs.setString('user_phone', user.phone!);
    if (user.address != null) await prefs.setString('user_address', user.address!);
    await prefs.setString('user_provider', user.provider);
    if (user.photo != null) {
      await prefs.setString('user_photo', user.photo!);
    } else {
      await prefs.remove('user_photo');
    }
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    notifyListeners();
  }

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final accessToken = prefs.getString('access_token');
    if (id != null && name != null && email != null && accessToken != null) {
      _user = UserModel(
        id: id,
        name: name,
        apellidos: prefs.getString('user_apellidos') ?? '',
        username: prefs.getString('user_username') ?? '',
        email: email,
        phone: prefs.getString('user_phone'),
        address: prefs.getString('user_address'),
        provider: prefs.getString('user_provider') ?? 'local',
        photo: prefs.getString('user_photo'),
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<bool> updateUser({
    required String name,
    required String apellidos,
    required String username,
    required String phone,
    required String address,
    String? photo,
  }) async {
    if (_user == null) return false;
    try {
      final updated = await _authService.updateUser(
        id: _user!.id,
        name: name,
        apellidos: apellidos,
        username: username,
        phone: phone,
        address: address,
        photo: photo,
      );
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';
      await saveSession(updated, accessToken, refreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}
