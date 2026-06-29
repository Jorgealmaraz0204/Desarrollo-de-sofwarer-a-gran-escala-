import 'package:flutter/material.dart';
import 'package:dsage/Realizar_pago_del_pedido.dart';

/// Ejemplo de cómo usar la pantalla de pago
///
/// Este archivo muestra cómo navegar a la pantalla de pago desde otra pantalla
/// con los parámetros requeridos.

class EjemploUsoPago extends StatelessWidget {
  const EjemploUsoPago({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo de Uso - Pago')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Crear datos de ejemplo
            final itemsPedido = [
              OrderItem(name: 'Pizza Margarita', price: 12.99, quantity: 2),
              OrderItem(name: 'Pizza Pepperoni', price: 14.99, quantity: 1),
              OrderItem(name: 'Coca Cola 2L', price: 3.50, quantity: 2),
              OrderItem(name: 'Papas Fritas', price: 4.99, quantity: 1),
            ];

            // Calcular subtotal
            double subtotal = 0;
            for (var item in itemsPedido) {
              subtotal += item.price * item.quantity;
            }

            // Navegar a la pantalla de pago
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PagoScreen(
                  orderId: 'ORD-2024-${DateTime.now().millisecondsSinceEpoch}',
                  items: itemsPedido,
                  subtotal: subtotal,
                  tax: subtotal * 0.08, // 8% de impuestos
                  shippingCost: 5.00,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text(
            'Ir a Pagar Pedido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Ejemplo de cómo crear órdenes desde una lista de productos
class ProductoCarrito {
  final String nombre;
  final double precio;
  int cantidad;

  ProductoCarrito({
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });
}

class GestorCarrito {
  final List<ProductoCarrito> _items = [];

  void agregarProducto(ProductoCarrito producto) {
    _items.add(producto);
  }

  void removerProducto(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  double obtenerSubtotal() {
    double total = 0;
    for (var item in _items) {
      total += item.precio * item.cantidad;
    }
    return total;
  }

  List<OrderItem> convertirAOrderItems() {
    return _items
        .map(
          (p) =>
              OrderItem(name: p.nombre, price: p.precio, quantity: p.cantidad),
        )
        .toList();
  }

  void limpiar() {
    _items.clear();
  }
}

/// Ejemplo de navegación desde la pantalla de carrito a pago
void ejemploNavegacionDesdePantallaPrincipal(BuildContext context) {
  // Crear gestor del carrito
  final carrito = GestorCarrito();

  // Agregar productos (ejemplo)
  carrito.agregarProducto(
    ProductoCarrito(nombre: 'Pizza Grande', precio: 18.99, cantidad: 1),
  );
  carrito.agregarProducto(
    ProductoCarrito(nombre: 'Sidra 2L', precio: 4.50, cantidad: 2),
  );

  // Obtener subtotal
  final subtotal = carrito.obtenerSubtotal();
  final impuestos = subtotal * 0.08;
  final envio = 5.00;

  // Navegar a la pantalla de pago
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PagoScreen(
        orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: carrito.convertirAOrderItems(),
        subtotal: subtotal,
        tax: impuestos,
        shippingCost: envio,
      ),
    ),
  );
}
