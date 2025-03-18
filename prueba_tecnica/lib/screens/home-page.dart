import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_tecnica/screens/providers.dart';
import 'package:prueba_tecnica/screens/recargas_page.dart';

class HomePage extends ConsumerWidget {
  final String token;
  final String nombreUsuario;
  final void Function(int)? onRealizarRecarga;

  const HomePage({
    super.key,
    required this.token,
    required this.nombreUsuario,
    this.onRealizarRecarga,
  });

  void _irAEditarTransaccion(
      BuildContext context, WidgetRef ref, String idTransaccion) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecargasPage(
          idTransaccion: idTransaccion,
          token: token,
        ),
      ),
    ).then((resultado) {
      if (resultado == true) {
        // ignore: unused_result
        ref.refresh(transaccionesProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lista de transacciones actualizada.'),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transaccionesAsync = ref.watch(transaccionesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido, $nombreUsuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola,',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Podrás realizar la recarga de tu teléfono móvil de manera rápida y segura.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (onRealizarRecarga != null) {
                  onRealizarRecarga!(1);
                }
              },
              icon: const Icon(Icons.phone_android),
              label: const Text('Realizar Recarga'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Últimas Transacciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: transaccionesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (transacciones) {
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: transacciones.length > 5
                              ? 5
                              : transacciones.length,
                          itemBuilder: (context, index) {
                            final transaccion =
                                transacciones.reversed.toList()[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.phone_android,
                                  color: Colors.deepPurple,
                                ),
                                title:
                                    Text('Recarga a ${transaccion['numero']}'),
                                subtitle: Text(
                                    '\$${transaccion['valor']} - ${transaccion['fecha']}'),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  _irAEditarTransaccion(context, ref,
                                      transaccion['id'].toString());
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (transacciones.length > 5)
                        TextButton(
                          onPressed: () {
                            if (onRealizarRecarga != null) {
                              onRealizarRecarga!(2);
                            }
                          },
                          child: const Text('Mostrar más'),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
