import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterProvider extends ChangeNotifier {
  final nameController = TextEditingController();
  final apellidosController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String? errorMessage;

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = 'Las contraseñas no coinciden';
      notifyListeners();
      return null;
    }
    if (passwordController.text.length < 8) {
      errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: nameController.text.trim(),
        apellidos: apellidosController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      return result;
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
    apellidosController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
