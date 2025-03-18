import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_tecnica/services/api_service.dart';

final tokenProvider = StateProvider<String?>((ref) => null);

final proveedoresProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null) {
    throw Exception('No autenticado');
  }
  return await ApiService.obtenerProveedores(token);
});

final transaccionesProvider = FutureProvider<List<dynamic>>((ref) async {
  final token = ref.watch(tokenProvider);
  if (token == null) {
    throw Exception('No autenticado');
  }
  return await ApiService.listarTransacciones(token);
});
