import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _oauthLogin(
    BuildContext context,
    String provider,
    String simulatedName,
    String simulatedEmail,
  ) async {
    // Mostrar diálogo de "conectando..."
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Conectando con $provider...',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              simulatedEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.of(context).pop(); // cerrar diálogo

    try {
      final result = await AuthService().oauthLogin(
        provider: provider.toLowerCase(),
        name: simulatedName,
        email: simulatedEmail,
      );

      if (!context.mounted) return;
      await context.read<AuthProvider>().saveSession(
            result['user'],
            result['accessToken'],
            result['refreshToken'],
          );

      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 90, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'FluxShop',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tu tienda favorita en tu bolsillo',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  color: Colors.white.withValues(alpha: 0.12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Botón iniciar sesión
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                          icon: const Icon(Icons.login),
                          label: const Text('Iniciar sesión', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black87,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Botón crear cuenta
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Crear cuenta', style: TextStyle(fontSize: 16)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Divisor
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.4))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'o continúa con',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.4))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Botón Google
                        _OAuthButton(
                          label: 'Continuar con Google',
                          color: Colors.white,
                          textColor: Colors.black87,
                          icon: _GoogleIcon(),
                          onPressed: () => _oauthLogin(
                            context,
                            'Google',
                            'Usuario FluxShop',
                            'usuario.fluxshop@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Botón Facebook
                        _OAuthButton(
                          label: 'Continuar con Facebook',
                          color: const Color(0xFF1877F2),
                          textColor: Colors.white,
                          icon: const Icon(Icons.facebook, color: Colors.white, size: 22),
                          onPressed: () => _oauthLogin(
                            context,
                            'Facebook',
                            'Usuario FluxShop',
                            'usuario.fluxshop@facebook.com',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Widget icon;
  final VoidCallback onPressed;

  const _OAuthButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        children: [
          Icon(Icons.circle, color: Color(0xFF4285F4), size: 22),
          Positioned.fill(
            child: Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
