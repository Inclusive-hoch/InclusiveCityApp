/// Servicio de autenticación simple
/// TODO: Integrar con el backend de autenticación real cuando esté disponible
class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Estado de autenticación actual
  String? _currentUserId;
  
  /// Obtiene el ID del usuario actualmente autenticado
  /// TODO: Reemplazar con la lógica real de obtención del usuario desde token JWT
  String? get currentUserId => _currentUserId;
  
  /// Verifica si hay un usuario autenticado
  bool get isAuthenticated => _currentUserId != null;
  
  /// Establece el usuario actual (para testing o después del login)
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }
  
  /// Cierra la sesión del usuario
  void logout() {
    _currentUserId = null;
  }
  
  /// Obtiene el userId o lanza excepción si no está autenticado
  String requireUserId() {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    return _currentUserId!;
  }
}
