import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al iniciar sesión';
      throw Exception(message);
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al registrarse';
      throw Exception(message);
    }
  }

  Future<UserModel> updateUser({
    required int id,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.users}/$id',
        data: {'name': name, 'phone': phone, 'address': address},
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Error al actualizar el perfil';
      throw Exception(message);
    }
  }
}
