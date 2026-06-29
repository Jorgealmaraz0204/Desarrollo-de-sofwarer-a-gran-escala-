import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Enums y modelos
enum PaymentStatus { pending, processing, confirmed, rejected }

enum PaymentMethod { card, cash }

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class Transaction {
  final String id;
  final DateTime date;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    required this.method,
  });
}

class PagoScreen extends StatefulWidget {
  final String orderId;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shippingCost;

  const PagoScreen({
    super.key,
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  PaymentMethod? selectedPaymentMethod;
  PaymentStatus paymentStatus = PaymentStatus.pending;
  bool showBillingForm = false;
  bool showTransactionHistory = false;

  // Controllers para formulario
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  // Historial de transacciones simulado
  late List<Transaction> transactionHistory;

  @override
  void initState() {
    super.initState();
    transactionHistory = [
      Transaction(
        id: 'TRX-001-${widget.orderId}',
        date: DateTime.now().subtract(const Duration(days: 1)),
        amount: widget.subtotal + widget.tax + widget.shippingCost,
        status: PaymentStatus.confirmed,
        method: PaymentMethod.card,
      ),
    ];
  }

  double get total => widget.subtotal + widget.tax + widget.shippingCost;

  Color getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.processing:
        return Colors.blue;
      case PaymentStatus.confirmed:
        return Colors.green;
      case PaymentStatus.rejected:
        return Colors.red;
    }
  }

  String getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pendiente';
      case PaymentStatus.processing:
        return 'Procesando...';
      case PaymentStatus.confirmed:
        return '✓ Confirmado';
      case PaymentStatus.rejected:
        return '✗ Rechazado';
    }
  }

  void _processPayment() {
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un método de pago')),
      );
      return;
    }

    if (!showBillingForm) {
      setState(() => showBillingForm = true);
      return;
    }

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    if (selectedPaymentMethod == PaymentMethod.card &&
        (cardNumberController.text.isEmpty ||
            expiryController.text.isEmpty ||
            cvvController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los datos de la tarjeta')),
      );
      return;
    }

    // Simular procesamiento
    setState(() => paymentStatus = PaymentStatus.processing);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => paymentStatus = PaymentStatus.confirmed);

      // Agregar transacción al historial
      transactionHistory.insert(
        0,
        Transaction(
          id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
          date: DateTime.now(),
          amount: total,
          status: PaymentStatus.confirmed,
          method: selectedPaymentMethod!,
        ),
      );

      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Pago Confirmado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 20),
            Text(
              'Pedido #${widget.orderId}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadInvoice();
            },
            child: const Text('Descargar Factura'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _goToDeliveryTracking();
            },
            child: const Text('Seguimiento de Entrega'),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Descargando factura...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _goToDeliveryTracking() {
    // Navegación a pantalla de seguimiento
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ir a seguimiento de entrega')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago del Pedido'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número de Pedido
              _buildOrderIdCard(),
              const SizedBox(height: 24),

              // Resumen del Pedido
              _buildOrderSummary(),
              const SizedBox(height: 24),

              // Estado de Pago
              _buildPaymentStatusIndicator(),
              const SizedBox(height: 24),

              // Métodos de Pago
              _buildPaymentMethodsSection(),
              const SizedBox(height: 24),

              // Formulario de Facturación
              if (showBillingForm) ...[
                _buildBillingFormSection(),
                const SizedBox(height: 24),
              ],

              // Mensaje de Seguridad
              _buildSecurityMessage(),
              const SizedBox(height: 24),

              // Botón de Confirmación
              _buildConfirmButton(),
              const SizedBox(height: 24),

              // Botón de Historial
              _buildTransactionHistoryButton(),
              const SizedBox(height: 24),

              // Historial de Transacciones
              if (showTransactionHistory)
                _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderIdCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Número de Pedido',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            '#${widget.orderId}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Productos
            ...widget.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.name} x${item.quantity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 20),
            // Subtotal
            _buildSummaryRow('Subtotal', widget.subtotal),
            const SizedBox(height: 8),
            // Impuestos
            _buildSummaryRow('Impuestos', widget.tax, Colors.orange),
            const SizedBox(height: 8),
            // Envío
            _buildSummaryRow('Costo de Envío', widget.shippingCost, Colors.blue),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color ?? Colors.grey),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusIndicator() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado del Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: getStatusColor(paymentStatus).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    paymentStatus == PaymentStatus.pending
                        ? Icons.schedule
                        : paymentStatus == PaymentStatus.processing
                            ? Icons.hourglass_empty
                            : paymentStatus == PaymentStatus.confirmed
                                ? Icons.check_circle
                                : Icons.cancel,
                    color: getStatusColor(paymentStatus),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getStatusText(paymentStatus),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(paymentStatus),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paymentStatus == PaymentStatus.pending
                            ? 'Esperando confirmación de pago'
                            : paymentStatus == PaymentStatus.processing
                                ? 'Tu pago está siendo procesado'
                                : paymentStatus == PaymentStatus.confirmed
                                    ? 'Tu pago fue confirmado exitosamente'
                                    : 'Hubo un problema con tu pago',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (paymentStatus == PaymentStatus.processing)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(
                    getStatusColor(paymentStatus),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Opción Tarjeta
            _buildPaymentMethodOption(
              PaymentMethod.card,
              Icons.credit_card,
              'Tarjeta de Crédito/Débito',
              'Visa, Mastercard, American Express',
            ),
            const SizedBox(height: 12),
            // Opción Efectivo
            _buildPaymentMethodOption(
              PaymentMethod.cash,
              Icons.payments,
              'Pago en Efectivo',
              'Al momento de la entrega',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
          if (method == PaymentMethod.cash) {
            showBillingForm = false;
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.deepPurple.withOpacity(0.05) : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepPurple
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingFormSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de Facturación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: nameController,
              label: 'Nombre Completo',
              icon: Icons.person,
            ),
            const SizedBox(height: 12),
            _buildTextFormField(
              controller: emailController,
              label: 'Correo Electrónico',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextFormField(
              controller: phoneController,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildTextFormField(
              controller: addressController,
              label: 'Dirección de Facturación',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            if (selectedPaymentMethod == PaymentMethod.card) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              const Text(
                'Datos de la Tarjeta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextFormField(
                controller: cardNumberController,
                label: 'Número de Tarjeta',
                icon: Icons.credit_card,
                placeholder: '1234 5678 9012 3456',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: expiryController,
                      label: 'MM/AA',
                      placeholder: '12/25',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextFormField(
                      controller: cvvController,
                      label: 'CVV',
                      placeholder: '123',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? placeholder,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.deepPurple,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔒 Conexión Segura',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tus datos están protegidos con encriptación SSL de 256 bits. '
                  'Tu información financiera nunca será compartida.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: paymentStatus == PaymentStatus.processing
            ? null
            : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: paymentStatus == PaymentStatus.processing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Procesando...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                paymentStatus == PaymentStatus.confirmed
                    ? 'Pago Confirmado ✓'
                    : 'Confirmar Pago - \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildTransactionHistoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() => showTransactionHistory = !showTransactionHistory);
        },
        icon: const Icon(Icons.history),
        label: Text(
          showTransactionHistory
              ? 'Ocultar Historial'
              : 'Ver Historial de Transacciones (${transactionHistory.length})',
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Transacciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...transactionHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              return Column(
                children: [
                  _buildTransactionItem(transaction),
                  if (index < transactionHistory.length - 1)
                    const Divider(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getStatusColor(transaction.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.method == PaymentMethod.card
                  ? Icons.credit_card
                  : Icons.payments,
              color: getStatusColor(transaction.status),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.method == PaymentMethod.card
                      ? 'Tarjeta'
                      : 'Efectivo',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(transaction.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  getStatusText(transaction.status),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(transaction.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
