/// Excepción lanzada cuando hay un error en el servidor
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Excepción lanzada cuando hay problemas de conectividad de red
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Excepción lanzada cuando hay problemas con el almacenamiento en caché
class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Excepción lanzada cuando la solicitud es incorrecta (400)
class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message);

  @override
  String toString() => 'BadRequestException: $message';
}

/// Excepción lanzada cuando el usuario no está autenticado (401)
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Excepción lanzada cuando el recurso no se encuentra (404)
class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Excepción lanzada cuando hay un conflicto con el estado actual (409)
class ConflictException implements Exception {
  final String message;

  ConflictException(this.message);

  @override
  String toString() => 'ConflictException: $message';
}

/// Excepción lanzada cuando se excede el tiempo de espera
class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Excepción lanzada cuando el usuario no tiene permisos suficientes (403)
class ForbiddenException implements Exception {
  final String message;

  ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Excepción lanzada cuando hay un error interno del servidor (500)
class InternalServerException implements Exception {
  final String message;
  final int? statusCode;

  InternalServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'InternalServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Excepción lanzada cuando falla la validación de datos
class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;

  ValidationException(this.message, [this.errors]);

  @override
  String toString() => 'ValidationException: $message${errors != null ? ' - Errores: $errors' : ''}';
}

/// Excepción lanzada cuando falla el parseo de datos JSON
class ParseException implements Exception {
  final String message;

  ParseException(this.message);

  @override
  String toString() => 'ParseException: $message';
}
