import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica/screens/providers.dart';
import 'package:prueba_tecnica/screens/recargas_page.dart';
import 'package:prueba_tecnica/services/api_service.dart';

class HistorialPage extends ConsumerStatefulWidget {
  final String token;
  const HistorialPage({super.key, required this.token});

  @override
  ConsumerState<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends ConsumerState<HistorialPage> {
  List<dynamic> _transacciones = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _ordenAscendente = false;

  @override
  void initState() {
    super.initState();
    _cargarTransacciones();
  }

  Future<void> _cargarTransacciones() async {
    try {
      final token = ref.read(tokenProvider);
      if (token == null) {
        throw Exception('No autenticado');
      }

      final transacciones = await ApiService.listarTransacciones(token);
      setState(() {
        _transacciones = transacciones;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _cambiarOrden() {
    setState(() {
      _ordenAscendente = !_ordenAscendente;
      _transacciones = _transacciones.reversed.toList();
    });
  }

  void _irAEditarTransaccion(String idTransaccion) {
    final token = ref.read(tokenProvider);
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No autenticado.')),
      );
      return;
    }

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
        _cargarTransacciones();
      }
    });
  }

  String _formatearValor(double valor) {
    final formatoMonetario = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatoMonetario.format(valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Transacciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _cambiarOrden,
              icon: const Icon(Iconsax.arrow_3),
              label: Text(
                _ordenAscendente ? 'Recientes' : 'Antiguos',
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : ListView.builder(
                          itemCount: _transacciones.length,
                          itemBuilder: (context, index) {
                            final transaccion = _transacciones[index];
                            final valorFormateado =
                                _formatearValor(transaccion['valor']);

                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                leading: const Icon(Icons.phone_android,
                                    color: Colors.deepPurple),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Recarga a ${transaccion['numero']}'),
                                    Text(
                                      'ID: ${transaccion['id']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Valor: $valorFormateado'),
                                    Text(
                                        'Fecha: ${_formatearFecha(transaccion['fecha'])}'),
                                  ],
                                ),
                                onTap: () {
                                  _irAEditarTransaccion(
                                      transaccion['id'].toString());
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(String fecha) {
    final dateTime = DateTime.parse(fecha);
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }
}
