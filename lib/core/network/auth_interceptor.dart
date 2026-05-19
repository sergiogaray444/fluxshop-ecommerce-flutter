import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isExpired = err.response?.data?['expired'] == true;
    if (err.response?.statusCode == 401 && isExpired) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      if (refreshToken != null) {
        try {
          final response = await dio.post(
            ApiConstants.refresh,
            data: {'refreshToken': refreshToken},
            options: Options(extra: {'skipInterceptor': true}),
          );
          final newAccess = response.data['accessToken'] as String;
          final newRefresh = response.data['refreshToken'] as String;
          await prefs.setString('access_token', newAccess);
          await prefs.setString('refresh_token', newRefresh);

          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await prefs.clear();
        }
      }
    }
    handler.next(err);
  }
}
