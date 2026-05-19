import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils/format_utils.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user!.id;
    _ordersFuture = _orderService.getOrders(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes pedidos', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = order['items'] as List<dynamic>? ?? [];
              final date = DateTime.tryParse(order['created_at'] ?? '');
              final dateStr = date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : '';
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text('#${order['id']}'),
                  ),
                  title: Text(
                    formatCOP(double.tryParse(order['total'].toString()) ?? 0),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dateStr),
                  trailing: Chip(
                    label: Text(
                      order['status'] ?? 'confirmed',
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.green.shade100,
                  ),
                  children: items.map<Widget>((item) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.shopping_bag_outlined, size: 20),
                      title: Text(item['product_name'] ?? ''),
                      subtitle: Text('Cantidad: ${item['quantity']}'),
                      trailing: Text(
                        formatCOP(double.tryParse(item['unit_price'].toString()) ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
