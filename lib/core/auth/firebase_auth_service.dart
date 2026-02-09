import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación que provee el Firebase ID Token
/// para autenticar requests al backend.
/// 
/// El backend usa Firebase Admin SDK para verificar estos tokens.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({required FirebaseAuth firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  /// Obtiene el Firebase ID Token del usuario actual.
  /// 
  /// Este token debe enviarse en el header `Authorization: Bearer <token>`
  /// para autenticar las requests al backend.
  /// 
  /// Retorna un string vacío si no hay usuario autenticado.
  /// 
  /// El token se refresca automáticamente si está próximo a expirar.
  Future<String> getIdToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      log('⚠️ No hay usuario autenticado en Firebase', name: 'FirebaseAuthService');
      return '';
    }

    try {
      // forceRefresh: false permite usar el token cacheado si aún es válido
      final token = await user.getIdToken();
      return token ?? '';
    } catch (e) {
      log('❌ Error obteniendo Firebase ID Token: $e', name: 'FirebaseAuthService');
      return '';
    }
  }

  /// Obtiene el UID del usuario actual.
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Verifica si hay un usuario autenticado.
  bool get isAuthenticated => _firebaseAuth.currentUser != null;
}
