import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(ApiConstants.products);
      final List data = response.data as List;
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } on DioException {
      throw Exception('No se pudieron cargar los productos');
    }
  }
}
