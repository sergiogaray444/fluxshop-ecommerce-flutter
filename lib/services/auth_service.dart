import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return {
        'user': UserModel.fromJson(response.data['user']),
        'accessToken': response.data['accessToken'] as String,
        'refreshToken': response.data['refreshToken'] as String,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al iniciar sesión';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String apellidos,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'apellidos': apellidos,
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return {
        'user': UserModel.fromJson(response.data['user']),
        'accessToken': response.data['accessToken'] as String,
        'refreshToken': response.data['refreshToken'] as String,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al registrarse';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> oauthLogin({
    required String provider,
    required String name,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.oauth,
        data: {'provider': provider, 'name': name, 'email': email},
      );
      return {
        'user': UserModel.fromJson(response.data['user']),
        'accessToken': response.data['accessToken'] as String,
        'refreshToken': response.data['refreshToken'] as String,
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error en autenticación';
      throw Exception(message);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        ApiConstants.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al cambiar contraseña';
      throw Exception(message);
    }
  }

  Future<UserModel> updateUser({
    required int id,
    required String name,
    required String apellidos,
    required String username,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.users}/$id',
        data: {'name': name, 'apellidos': apellidos, 'username': username, 'phone': phone, 'address': address},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al actualizar el perfil';
      throw Exception(message);
    }
  }
}
