import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<UserModel?> login() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      return user;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
