import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prueba_tecnica/screens/providers.dart';
import 'package:prueba_tecnica/services/api_service.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatoMonetario = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final soloNumeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final valorNumerico = int.tryParse(soloNumeros) ?? 0;
    final valorFormateado = _formatoMonetario.format(valorNumerico);

    return TextEditingValue(
      text: valorFormateado,
      selection: TextSelection.collapsed(offset: valorFormateado.length),
    );
  }
}

class RecargasPage extends ConsumerStatefulWidget {
  final String? idTransaccion;
  final String token;

  const RecargasPage({super.key, this.idTransaccion, required this.token});

  @override
  ConsumerState<RecargasPage> createState() => _RecargasPageState();
}

class _RecargasPageState extends ConsumerState<RecargasPage> {
  bool cargandoProveedores = true;
  List<dynamic> proveedores = [];
  String? proveedorSeleccionado;

  final TextEditingController numeroController = TextEditingController();
  final TextEditingController valorController = TextEditingController();
  bool botonHabilitado = false;
  String? errorNumero;
  String? errorValor;

  final NumberFormat _formatoMonetario = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  final List<int> valoresPredefinidos = [
    1000,
    5000,
    10000,
    20000,
    50000,
    100000,
  ];

  void _seleccionarValor(int valor) {
    setState(() {
      valorController.text = _formatoMonetario.format(valor);
      validarCampos();
    });
  }

  @override
  void initState() {
    super.initState();
    valorController.addListener(validarCampos);
    numeroController.addListener(validarCampos);
    _cargarProveedores();

    if (widget.idTransaccion != null) {
      cargarTransaccion();
    }
  }

  Future<void> _cargarProveedores() async {
    try {
      final token = ref.read(tokenProvider);
      if (token == null) {
        throw Exception('No autenticado');
      }

      final response = await ApiService.obtenerProveedores(token);
      setState(() {
        proveedores = response;
        cargandoProveedores = false;
      });

      if (widget.idTransaccion != null) {
        cargarTransaccion();
      }
    } catch (e) {
      setState(() {
        cargandoProveedores = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar proveedores: $e')),
      );
    }
  }

  Future<void> cargarTransaccion() async {
    try {
      final token = ref.read(tokenProvider);
      if (token == null) {
        throw Exception('No autenticado');
      }

      final transaccion = await ApiService.obtenerTransaccionId(
        widget.idTransaccion!,
        token,
      );
      setState(() {
        numeroController.text = transaccion['numero'];
        valorController.text = _formatoMonetario.format(transaccion['valor']);
        if (transaccion['proveedor'] != null) {
          final proveedorId = transaccion['proveedor']['id'].toString();
          proveedorSeleccionado = proveedorId;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar transacción: $e')),
      );
    }
  }

  @override
  void dispose() {
    numeroController.dispose();
    valorController.dispose();
    super.dispose();
  }

  void validarCampos() {
    final numero = numeroController.text;
    final valor = valorController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final esNumeroValido =
        numero.isEmpty || RegExp(r'^3\d{9}$').hasMatch(numero);
    final valorNumerico = int.tryParse(valor) ?? 0;
    final esValorValido =
        valor.isEmpty || (valorNumerico >= 1000 && valorNumerico <= 100000);

    setState(() {
      errorNumero = esNumeroValido
          ? null
          : 'El número debe tener 10 dígitos y comenzar con 3.';
      errorValor =
          esValorValido ? null : 'El valor debe estar entre 1,000 y 100,000.';
      botonHabilitado = esNumeroValido &&
          esValorValido &&
          numero.isNotEmpty &&
          valor.isNotEmpty;
    });
  }

  Future<Map<String, dynamic>?> confirmarPago() async {
    try {
      if (proveedorSeleccionado == null) {
        throw Exception('Por favor, selecciona un proveedor.');
      }

      final proveedor = proveedores.firstWhere(
        (p) => p['id'].toString() == proveedorSeleccionado,
        orElse: () => {'id': '', 'name': 'Proveedor no válido'},
      );

      if (proveedor['id'] == '') {
        throw Exception('Proveedor no válido.');
      }

      final token = ref.read(tokenProvider);
      if (token == null) {
        throw Exception('No autenticado.');
      }

      final requestBody = {
        "proveedorId": proveedor['id'],
        "numero": numeroController.text,
        "valor": double.tryParse(
                valorController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0.0,
      };

      Map<String, dynamic> respuesta;

      if (widget.idTransaccion != null) {
        respuesta = await ApiService.editarTransaccion(
          id: widget.idTransaccion!,
          proveedorId: proveedor['id'],
          numero: numeroController.text,
          valor: requestBody["valor"],
          token: token,
        );
        respuesta['estado'] = respuesta['estado'] ?? 'Actualizado';
      } else {
        respuesta = await ApiService.realizarRecarga(
          proveedorId: proveedor['id'],
          numero: numeroController.text,
          valor: requestBody["valor"],
          token: token,
        );
      }

      return respuesta;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> eliminarTransaccion() async {
    try {
      final token = ref.read(tokenProvider);
      if (token == null) {
        throw Exception('No autenticado');
      }
      if (widget.idTransaccion == null) {
        throw Exception('ID de transacción no válido');
      }
      await ApiService.eliminarTransaccion(widget.idTransaccion!, token);

      ref.refresh(transaccionesProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transacción eliminada exitosamente.'),
          backgroundColor: Colors.deepPurple,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar transacción: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void mostrarDialogoEliminacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content:
              Text('¿Estás seguro de que deseas eliminar esta transacción?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await eliminarTransaccion();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transacción eliminada exitosamente.'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
              child: Text(
                'Eliminar',
                style: TextStyle(color: const Color.fromARGB(255, 255, 17, 0)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoConfirmacion(BuildContext context,
      Map<String, dynamic> respuesta, bool esEdicion) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  esEdicion ? "¡Recarga actualizada!" : "¡Recarga completada!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "${_formatoMonetario.format(respuesta['valor'])}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Estado: ${respuesta['estado'] ?? 'Procesado'}"),
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.deepPurple),
                  title: Text("N° de celular: ${respuesta['numero']}"),
                ),
                if (respuesta['id'] != null)
                  ListTile(
                    leading: Icon(Icons.receipt, color: Colors.deepPurple),
                    title: Text("ID de operación: ${respuesta['id']}"),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text("Cerrar"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recargas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cargandoProveedores
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text('Selecciona un proveedor'),
                    value: proveedorSeleccionado,
                    items: proveedores.map((proveedor) {
                      return DropdownMenuItem<String>(
                        value: proveedor['id'].toString(),
                        child: Text(proveedor['name']),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        proveedorSeleccionado = valor;
                      });
                    },
                  ),
            const SizedBox(height: 20),
            TextField(
              controller: numeroController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número móvil',
                errorText: errorNumero,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor de recarga',
                errorText: errorValor,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CurrencyInputFormatter(),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: valoresPredefinidos.map((valor) {
                return ElevatedButton(
                  onPressed: () => _seleccionarValor(valor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_formatoMonetario.format(valor)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (widget.idTransaccion != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: botonHabilitado
                          ? () async {
                              final respuesta = await confirmarPago();
                              if (respuesta != null) {
                                await _mostrarDialogoConfirmacion(
                                    context, respuesta, true);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Editar recarga'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        mostrarDialogoEliminacion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            if (widget.idTransaccion == null)
              ElevatedButton(
                onPressed: botonHabilitado
                    ? () async {
                        final respuesta = await confirmarPago();
                        if (respuesta != null) {
                          await _mostrarDialogoConfirmacion(
                              context, respuesta, false);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmar pago'),
              ),
          ],
        ),
      ),
    );
  }
}
