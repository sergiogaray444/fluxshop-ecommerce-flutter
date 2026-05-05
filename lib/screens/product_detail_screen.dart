import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/format_utils.dart';
import '../core/widgets/product_image.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product =
        ModalRoute.of(context)!.settings.arguments as ProductModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del producto'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ProductImage(
              imageUrl: product.imageUrl,
              productName: product.name,
              height: 260,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chip de categoría
                  Chip(
                    label: Text(
                      product.category,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF1565C0)),
                    ),
                    backgroundColor: const Color(0xFFE3F2FD),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 10),
                  // Nombre
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A3D62),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Precio
                  Text(
                    formatCOP(product.price),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stock
                  Row(
                    children: [
                      Icon(
                        product.stock > 0
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: product.stock > 0 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        product.stock > 0
                            ? 'En stock (${product.stock} disponibles)'
                            : 'Agotado',
                        style: TextStyle(
                          color:
                              product.stock > 0 ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A3D62),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Selector de cantidad
                  Row(
                    children: [
                      const Text(
                        'Cantidad:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFF1565C0),
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _quantity < product.stock
                            ? () => setState(() => _quantity++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFF1565C0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Botón agregar al carrito
                  ElevatedButton.icon(
                    onPressed: product.stock > 0
                        ? () {
                            context.read<CartProvider>().addProduct(
                                  product,
                                  quantity: _quantity,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${product.name} agregado al carrito'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Agregar al carrito'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
