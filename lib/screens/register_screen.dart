import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/register_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static Widget init() {
    return ChangeNotifierProvider(
      create: (_) => RegisterProvider(),
      child: const RegisterScreen(),
    );
  }

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();

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
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A3D62),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Únete a FluxShop hoy',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        _field(
                          controller: provider.nameController,
                          label: 'Nombre',
                          icon: Icons.person_outlined,
                          capitalization: TextCapitalization.words,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El nombre es requerido';
                            if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: provider.apellidosController,
                          label: 'Apellidos',
                          icon: Icons.person_outlined,
                          capitalization: TextCapitalization.words,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Los apellidos son requeridos';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: provider.usernameController,
                          label: 'Nombre de usuario',
                          icon: Icons.alternate_email,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'El usuario es requerido';
                            if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: provider.emailController,
                          label: 'Correo electrónico',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'El correo es requerido';
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: provider.passwordController,
                          label: 'Contraseña',
                          icon: Icons.lock_outlined,
                          obscure: provider.obscurePassword,
                          suffix: GestureDetector(
                            onTap: () => context.read<RegisterProvider>().togglePassword(),
                            child: Icon(provider.obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'La contraseña es requerida';
                            if (v.length < 8) return 'Mínimo 8 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _field(
                          controller: provider.confirmPasswordController,
                          label: 'Confirmar contraseña',
                          icon: Icons.lock_outlined,
                          obscure: provider.obscureConfirm,
                          suffix: GestureDetector(
                            onTap: () => context.read<RegisterProvider>().toggleConfirm(),
                            child: Icon(provider.obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                            if (v != provider.passwordController.text) {
                              return 'Las contraseñas no coinciden';
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
                                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
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
                                        .read<RegisterProvider>()
                                        .register();
                                    if (result != null && context.mounted) {
                                      await context
                                          .read<AuthProvider>()
                                          .saveSession(
                                            result['user'],
                                            result['accessToken'],
                                            result['refreshToken'],
                                          );
                                      if (context.mounted) {
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          AppRoutes.home,
                                          (_) => false,
                                        );
                                      }
                                    }
                                  }
                                },
                                child: const Text('Crear cuenta'),
                              ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('¿Ya tienes cuenta?'),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed(AppRoutes.login),
                              child: const Text('Inicia sesión'),
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
