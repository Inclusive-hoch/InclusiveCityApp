import 'package:firebase_auth/firebase_auth.dart';

String mapAuthErrorToMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'No existe un usuario registrado con ese correo electrónico.';
      case 'wrong-password':
        return 'La contraseña ingresada es incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas. Verifica tu correo y contraseña.';
      case 'invalid-email':
        return 'El correo electrónico no tiene un formato válido.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con ese correo electrónico.';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Usa una más segura.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Contacta soporte.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta nuevamente en unos minutos.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Revisa tu red e inténtalo otra vez.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este correo usando otro método de acceso.';
      case 'operation-not-allowed':
        return 'Esta operación no está habilitada actualmente.';
      default:
        return 'Ocurrió un error de autenticación. Intenta nuevamente.';
    }
  }

  final errorText = error.toString().toLowerCase();
  if (errorText.contains('aborted by user') ||
      errorText.contains('cancel') ||
      errorText.contains('canceled')) {
    return 'Inicio de sesión cancelado por el usuario.';
  }

  return 'Ocurrió un error inesperado. Intenta nuevamente.';
}
