import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_app/core/constants/api_constants.dart';

/// Servicio temporal de autenticacion para desarrollo.
/// TODO: Eliminar cuando el servicio de Auth real este listo.
class TempAuthService {
  static const String _tokenKey = 'temp_jwt_token';
  final SharedPreferences prefs;
  final http.Client client;

  TempAuthService({
    required this.prefs,
    required this.client,
  });

  /// Realiza login con credenciales provistas.
  /// Guarda el token JWT en SharedPreferences.
  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['data']['token'] as String;
        await prefs.setString(_tokenKey, token);
        log('✅ Login exitoso');
      } else {
        log('❌ Error en login: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Error en login temporal: $e');
    }
  }

  /// Obtiene el token guardado.
  /// Retorna string vacío si no hay token.
  String getToken() {
    final token = prefs.getString(_tokenKey) ?? '';
    if (token.isEmpty) {
      log('⚠️ No hay token guardado');
    }
    return token;
  }

  /// Limpia el token guardado (para logout futuro).
  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
    log('🗑️ Token eliminado');
  }
}
