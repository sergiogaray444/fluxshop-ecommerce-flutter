import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/navigation/app_routes.dart';
import '../core/utils/format_utils.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

enum _PaymentMethod { card, pse, cash }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  _PaymentMethod _selected = _PaymentMethod.card;
  final _formKey = GlobalKey<FormState>();

  // Campos tarjeta
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // Campos PSE
  final _bankController = TextEditingController();
  final _docController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _bankController.dispose();
    _docController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_selected == _PaymentMethod.card || _selected == _PaymentMethod.pse) {
      if (!_formKey.currentState!.validate()) return;
    }

    setState(() => _isProcessing = true);

    // Mostrar diálogo de procesando
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Procesando pago...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              _selected == _PaymentMethod.card
                  ? 'Verificando tarjeta'
                  : _selected == _PaymentMethod.pse
                      ? 'Conectando con tu banco'
                      : 'Confirmando pedido',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );

    // Simular procesamiento (2.5s)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;
    Navigator.of(context).pop(); // cerrar diálogo de procesando

    // Crear la orden en el backend
    final userId = context.read<AuthProvider>().user?.id ?? 0;
    final success = await context.read<CartProvider>().confirmOrder(userId);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.orderSuccess,
        (route) => route.settings.name == AppRoutes.home,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar el pago. Inténtalo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Método de pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del monto
            _buildAmountCard(cart),
            const SizedBox(height: 20),
            // Selección de método
            const Text('Selecciona tu método de pago',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A3D62))),
            const SizedBox(height: 12),
            _buildMethodSelector(),
            const SizedBox(height: 20),
            // Formulario según método
            Form(
              key: _formKey,
              child: _selected == _PaymentMethod.card
                  ? _buildCardForm()
                  : _selected == _PaymentMethod.pse
                      ? _buildPseForm()
                      : _buildCashInfo(cart),
            ),
            const SizedBox(height: 28),
            // Botón pagar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pay,
                icon: const Icon(Icons.lock_outlined),
                label: Text(
                  _selected == _PaymentMethod.cash
                      ? 'Confirmar pedido'
                      : 'Pagar ${formatCOP(cart.total)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    'Pago 100% seguro y encriptado',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0A3D62)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total a pagar', style: TextStyle(color: Colors.white70, fontSize: 13)),
              SizedBox(height: 4),
            ],
          ),
          Text(
            formatCOP(cart.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      children: [
        _methodTile(
          value: _PaymentMethod.card,
          icon: Icons.credit_card,
          title: 'Tarjeta de crédito / débito',
          subtitle: 'Visa, Mastercard, Amex',
        ),
        const SizedBox(height: 8),
        _methodTile(
          value: _PaymentMethod.pse,
          icon: Icons.account_balance,
          title: 'PSE',
          subtitle: 'Débito desde tu cuenta bancaria',
        ),
        const SizedBox(height: 8),
        _methodTile(
          value: _PaymentMethod.cash,
          icon: Icons.money,
          title: 'Efectivo / Contraentrega',
          subtitle: 'Paga cuando llegue tu pedido',
        ),
      ],
    );
  }

  Widget _methodTile({
    required _PaymentMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selected == value;
    return GestureDetector(
      onTap: () => setState(() => _selected = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? const Color(0xFF1565C0) : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFF1565C0).withValues(alpha: 0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF1565C0) : Colors.grey, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? const Color(0xFF0A3D62) : Colors.black87)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? const Color(0xFF1565C0) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Column(
      children: [
        // Vista previa de la tarjeta
        Container(
          width: double.infinity,
          height: 110,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF283593)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.credit_card, color: Colors.white70, size: 28),
                  Text(
                    _expiryController.text.isEmpty ? 'MM/AA' : _expiryController.text,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cardNumberController.text.isEmpty
                        ? '**** **** **** ****'
                        : _cardNumberController.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    _cardNameController.text.isEmpty ? 'NOMBRE TITULAR' : _cardNameController.text.toUpperCase(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Número de tarjeta
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberFormatter(),
          ],
          maxLength: 19,
          decoration: const InputDecoration(
            labelText: 'Número de tarjeta',
            prefixIcon: Icon(Icons.credit_card),
            counterText: '',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            if (v == null || v.replaceAll(' ', '').length < 16) {
              return 'Ingresa un número de tarjeta válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _cardNameController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Nombre del titular',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryFormatter(),
                ],
                maxLength: 5,
                decoration: const InputDecoration(
                  labelText: 'MM/AA',
                  prefixIcon: Icon(Icons.calendar_month),
                  counterText: '',
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.length < 5) ? 'Fecha inválida' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 3,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  prefixIcon: Icon(Icons.lock_outlined),
                  counterText: '',
                ),
                validator: (v) => (v == null || v.length < 3) ? 'CVV inválido' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPseForm() {
    const banks = [
      'Bancolombia', 'Banco de Bogotá', 'Davivienda',
      'BBVA', 'Banco Popular', 'Nequi',
    ];
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Selecciona tu banco',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: banks
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: (v) => _bankController.text = v ?? '',
          validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un banco' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _docController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Número de documento',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          validator: (v) => (v == null || v.length < 6) ? 'Documento inválido' : null,
        ),
      ],
    );
  }

  Widget _buildCashInfo(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          const Text(
            'Pago contra entrega',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Pagarás ${formatCOP(cart.total)} cuando recibas tu pedido.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ten el monto exacto listo para el repartidor.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Formateadores de input
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digitsOnly[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
