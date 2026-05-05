import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../core/utils/format_utils.dart';
import '../core/widgets/product_image.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi carrito'),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Ver productos'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(180, 44)),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Lista de ítems
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Imagen
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: ProductImage(
                                    imageUrl: item.product.imageUrl,
                                    productName: item.product.name,
                                    height: 72,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Información del producto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${formatCOP(item.product.price)} c/u',
                                      style: const TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Controles de cantidad
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => context
                                            .read<CartProvider>()
                                            .decreaseQuantity(
                                                item.product.id),
                                        child: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Color(0xFF1565C0),
                                          size: 24,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => context
                                            .read<CartProvider>()
                                            .increaseQuantity(
                                                item.product.id),
                                        child: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFF1565C0),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatCOP(item.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A3D62),
                                      fontSize: 13,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context
                                        .read<CartProvider>()
                                        .removeProduct(item.product.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 24),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Eliminar',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Resumen del pedido
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cart.itemCount} producto${cart.itemCount != 1 ? 's' : ''}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            formatCOP(cart.total),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A3D62),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      cart.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final userId = auth.user?.id ?? 0;
                                final success = await context
                                    .read<CartProvider>()
                                    .confirmOrder(userId);
                                if (context.mounted) {
                                  if (success) {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      AppRoutes.orderSuccess,
                                      (route) =>
                                          route.settings.name ==
                                          AppRoutes.home,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Error al confirmar el pedido. Inténtalo de nuevo.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Confirmar pedido'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
