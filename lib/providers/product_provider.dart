import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<ProductModel> _products = [];
  bool isLoading = false;
  String? errorMessage;

  List<ProductModel> get products => _products;

  Future<void> loadProducts() async {
    if (_products.isNotEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _products = await _service.getProducts();
    } catch (e) {
      errorMessage = 'Servidor no disponible. Mostrando productos de ejemplo.';
      _products = _mockProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _products = [];
    await loadProducts();
  }

  List<ProductModel> _mockProducts() {
    return [
      ProductModel(
        id: 1,
        name: 'Laptop Lenovo IdeaPad 3',
        description:
            'Procesador Intel Core i5 12ª gen, 8GB RAM, 512GB SSD. Pantalla 15.6" Full HD. Perfecta para estudio y trabajo profesional.',
        price: 2899000,
        imageUrl: 'assets/images/products/laptop.jpg',
        category: 'Portátiles',
        stock: 10,
      ),
      ProductModel(
        id: 2,
        name: 'Samsung Galaxy A55',
        description:
            'Pantalla Super AMOLED 6.6", triple cámara 50MP, 8GB RAM y batería 5000mAh con carga rápida de 25W.',
        price: 1499000,
        imageUrl: 'assets/images/products/smartphone.jpg',
        category: 'Smartphones',
        stock: 15,
      ),
      ProductModel(
        id: 3,
        name: 'Audífonos Sony WH-1000XM5',
        description:
            'Cancelación activa de ruido líder en la industria, 30h de batería, Hi-Res Audio y micrófono con IA integrada.',
        price: 1199000,
        imageUrl: 'assets/images/products/headphones.jpg',
        category: 'Audio',
        stock: 20,
      ),
      ProductModel(
        id: 4,
        name: 'iPad 10ª Generación',
        description:
            'Pantalla Liquid Retina 10.9", chip A14 Bionic, 64GB almacenamiento y conector USB-C. Compatible con Apple Pencil.',
        price: 2299000,
        imageUrl: 'assets/images/products/tablet.jpg',
        category: 'Tablets',
        stock: 8,
      ),
      ProductModel(
        id: 5,
        name: 'Monitor LG 24" Full HD',
        description:
            'Panel IPS 75Hz, resolución 1920×1080, entradas HDMI y VGA. Colores precisos y amplio ángulo de visión para home office.',
        price: 699000,
        imageUrl: 'assets/images/products/monitor.jpg',
        category: 'Monitores',
        stock: 12,
      ),
      ProductModel(
        id: 6,
        name: 'Teclado Mecánico Redragon K552',
        description:
            'Switches Outemu Blue, retroiluminación LED roja, diseño compacto TKL y base metálica resistente. Ideal para gaming y programación.',
        price: 189000,
        imageUrl: 'assets/images/products/keyboard.jpg',
        category: 'Periféricos',
        stock: 30,
      ),
      ProductModel(
        id: 7,
        name: 'Mouse Logitech MX Master 3S',
        description:
            'Sensor 8000 DPI, scroll MagSpeed electromagnético, conexión USB o Bluetooth. Diseño ergonómico para uso prolongado.',
        price: 399000,
        imageUrl: 'assets/images/products/mouse.jpg',
        category: 'Periféricos',
        stock: 25,
      ),
      ProductModel(
        id: 8,
        name: 'Smartwatch Samsung Galaxy Watch 6',
        description:
            'Pantalla Super AMOLED 1.5", monitor de salud 24/7, GPS integrado, resistencia al agua 5ATM y batería de hasta 40 horas.',
        price: 799000,
        imageUrl: 'assets/images/products/smartwatch.jpg',
        category: 'Wearables',
        stock: 14,
      ),
    ];
  }
}
