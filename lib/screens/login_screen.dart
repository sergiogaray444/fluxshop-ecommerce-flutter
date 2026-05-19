import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget init() {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: const LoginScreen(),
    );
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  void _showForgotPassword(BuildContext context) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailCtrl.text.trim().isEmpty) return;
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Enlace enviado a ${emailCtrl.text.trim()}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A3D62), Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A3D62),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bienvenido de vuelta a FluxShop',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: provider.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El correo es requerido';
                            }
                            final emailRegex =
                                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: provider.passwordController,
                          obscureText: provider.obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  context.read<LoginProvider>().togglePassword(),
                              child: Icon(
                                provider.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La contraseña es requerida';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        provider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final result = await context
                                        .read<LoginProvider>()
                                        .login();
                                    if (result != null && context.mounted) {
                                      await context
                                          .read<AuthProvider>()
                                          .saveSession(
                                            result['user'],
                                            result['accessToken'],
                                            result['refreshToken'],
                                          );
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                          AppRoutes.home,
                                          (_) => false,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Iniciar sesión'),
                              ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPassword(context),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿No tienes cuenta?'),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.register),
                              child: const Text('Regístrate'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
