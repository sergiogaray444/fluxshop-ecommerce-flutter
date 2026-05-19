import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/cart_item_model.dart';

class OrderService {
  final Dio _dio = DioClient().dio;

  Future<void> createOrder({
    required int userId,
    required List<CartItemModel> items,
    required double total,
    required String shippingAddress,
    required String shippingCity,
    required String shippingZip,
    required String paymentMethod,
  }) async {
    try {
      await _dio.post(
        ApiConstants.orders,
        data: {
          'user_id': userId,
          'total': total,
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity,
          'shipping_zip': shippingZip,
          'payment_method': paymentMethod,
          'items': items
              .map((item) => {
                    'product_id': item.product.id,
                    'quantity': item.quantity,
                    'unit_price': item.product.price,
                  })
              .toList(),
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al confirmar la orden';
      throw Exception(message);
    }
  }

  Future<List<Map<String, dynamic>>> getOrders(int userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: {'user_id': userId},
      );
      return List<Map<String, dynamic>>.from(response.data as List);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Error al obtener los pedidos';
      throw Exception(message);
    }
  }
}
