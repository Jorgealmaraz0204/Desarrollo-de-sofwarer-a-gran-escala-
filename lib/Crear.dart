import 'dart:io';

void main() {
  List<String> pizza = [];

  while (true) {
    print('\n=== PIZZERÍA ===');
    print('1. Agregar Salsa');
    print('2. Agregar Queso');
    print('3. Agregar Pepperoni');
    print('4. Agregar Hongos');
    print('5. Agregar Albahaca');
    print('6. Ver Pizza');
    print('7. Confirmar Pedido');
    print('8. Salir');

    stdout.write('Opción: ');
    String? opcion = stdin.readLineSync();

    switch (opcion) {
      case '1':
        pizza.add('Salsa');
        print('Salsa agregada.');
        break;

      case '2':
        pizza.add('Queso');
        print('Queso agregado.');
        break;

      case '3':
        pizza.add('Pepperoni');
        print('Pepperoni agregado.');
        break;

      case '4':
        pizza.add('Hongos');
        print('Hongos agregados.');
        break;

      case '5':
        pizza.add('Albahaca');
        print('Albahaca agregada.');
        break;

      case '6':
        print('\nIngredientes actuales:');
        if (pizza.isEmpty) {
          print('La pizza está vacía.');
        } else {
          for (var ingrediente in pizza) {
            print('- $ingrediente');
          }
        }
        break;

      case '7':
        if (pizza.isEmpty) {
          print('No puedes confirmar una pizza vacía.');
        } else {
          print('\nPedido confirmado.');
          print('Ingredientes:');
          for (var ingrediente in pizza) {
            print('- $ingrediente');
          }
          pizza.clear();
        }
        break;

      case '8':
        print('Gracias por usar la pizzería.');
        return;

      default:
        print('Opción inválida.');
    }
  }
}