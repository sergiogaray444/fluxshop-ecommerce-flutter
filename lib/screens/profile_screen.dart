import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0A3D62)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white24,
                    backgroundImage: user?.photo != null
                        ? MemoryImage(base64Decode(user!.photo!))
                        : null,
                    child: user?.photo == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${user?.name ?? 'Usuario'} ${user?.apellidos ?? ''}'.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.username.isNotEmpty == true)
                    Text(
                      '@${user!.username}',
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Datos de la cuenta
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoTile(Icons.person, 'Nombre', user?.name ?? '-'),
                  _infoTile(Icons.person_outlined, 'Apellidos', user?.apellidos.isNotEmpty == true ? user!.apellidos : '-'),
                  _infoTile(Icons.alternate_email, 'Usuario', user?.username.isNotEmpty == true ? '@${user!.username}' : '-'),
                  _infoTile(Icons.email, 'Correo electrónico', user?.email ?? '-'),
                  _infoTile(Icons.phone, 'Teléfono', user?.phone ?? 'No registrado'),
                  _infoTile(Icons.location_on, 'Dirección', user?.address ?? 'No registrada'),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Botón editar perfil
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.editProfile),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar perfil'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón cambiar contraseña
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.changePassword),
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Cambiar contraseña'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón cerrar sesión
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (_) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00E5FF)),
        title: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
