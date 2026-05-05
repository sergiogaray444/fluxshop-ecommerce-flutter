import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RegisterProvider extends ChangeNotifier {
  final nameController = TextEditingController();
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

  Future<UserModel?> register() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        nameController.text.trim(),
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
