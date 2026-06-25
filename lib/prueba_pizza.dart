void main() {
  print('--- 🍕 SISTEMA DE PIZZAS (CONSOLA DART) 🍕 ---');

  // 1. Datos del pedido (Simulando lo que elige el usuario)
  String tamano = 'Grande';
  int cantidad = 2;
  List<String> ingredientesExtra = ['Queso Extra', 'Pepperoni'];

  // 2. Precios base
  double precioBase = 0.0;
  if (tamano == 'Chica') precioBase = 100.0;
  if (tamano == 'Mediana') precioBase = 150.0;
  if (tamano == 'Grande') precioBase = 200.0;

  double precioPorIngrediente = 15.0;

  // 3. Cálculos
  double costoExtras = ingredientesExtra.length * precioPorIngrediente;
  double totalPorPizza = precioBase + costoExtras;
  double totalFinal = totalPorPizza * cantidad;

  // 4. Mostrar el ticket en consola
  print('Tamaño seleccionado: $tamano (\$${precioBase.toStringAsFixed(2)})');
  print('Ingredientes extra: ${ingredientesExtra.join(', ')} (+\$${costoExtras.toStringAsFixed(2)})');
  print('Cantidad: $cantidad');
  print('-----------------------------------------');
  print('TOTAL A PAGAR: \$${totalFinal.toStringAsFixed(2)}');
  print('-----------------------------------------');
  print('¡Pedido simulado con éxito! 🚀');
}