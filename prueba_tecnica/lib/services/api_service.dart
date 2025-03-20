import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<Map<String, String>?> autenticar({
    required String user,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/auth/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-api-key':
              'mtrQF6Q11eosqyQnkMY0JGFbGqcxVg5icvfVnX1ifIyWDvwGApJ8WUM8nHVrdSkN',
        },
        body: json.encode({'user': user, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          return {
            'token': data['token'],
            'nombreUsuario': user,
          };
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> realizarRecarga({
    required String proveedorId,
    required String numero,
    required double valor,
    required String token,
  }) async {
    try {
      final requestBody = {
        "valor": valor,
        "numero": numero,
        "proveedorId": proveedorId,
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/transacciones/buy'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Error al realizar la recarga."};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión."};
    }
  }

  static Future<List<dynamic>> listarTransacciones(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/transacciones/listar'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Error al listar transacciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<List<dynamic>> obtenerProveedores(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://us-central1-puntored-dev.cloudfunctions.net/technicalTest-developer/api/getSuppliers?=null'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer e8797850-95bb-4ca1-ac52-c99dd3c3cbad',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener proveedores: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> editarTransaccion({
    required String id,
    required String proveedorId,
    required String numero,
    required double valor,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/transacciones/editar/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "proveedorId": proveedorId,
          "numero": numero,
          "valor": valor,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Error al editar la transacción."};
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión."};
    }
  }

  static Future<Map<String, dynamic>> obtenerTransaccionId(
      String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/transacciones/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Pasa el token aquí
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Error al obtener la transacción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<Map<String, dynamic>> obtenerEstadoPago(
      String id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/transacciones/estado/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Error al obtener el estado del pago: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> eliminarTransaccion(String id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8080/transacciones/delete/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Error al eliminar la transacción: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
