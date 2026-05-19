class ApiConstants {
  // Emulador Android:  http://10.0.2.2:3000
  // Dispositivo físico: http://192.168.80.14:3000  (ejecuta ipconfig para verificar)
  static const String baseUrl = 'http://192.168.80.13:3000';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String oauth = '/auth/oauth';
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String users = '/users';
}
