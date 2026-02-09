import 'package:flutter/material.dart';

/// Extensión para obtener iconos y nombres según el tipo de spot.
extension SpotTypeExtension on String? {
  /// Retorna el icono apropiado según el tipo de spot.
  IconData get spotIcon {
    switch (this?.toLowerCase()) {
      case 'home':
      case 'casa':
        return Icons.home;
      case 'work':
      case 'trabajo':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }

  /// Retorna un nombre legible según el tipo de spot.
  String get spotTypeName {
    switch (this?.toLowerCase()) {
      case 'home':
      case 'casa':
        return 'Casa';
      case 'work':
      case 'trabajo':
        return 'Trabajo';
      default:
        return 'Lugar guardado';
    }
  }

  /// Retorna si el tipo es predefinido (casa o trabajo).
  bool get isPredefinedType {
    final type = this?.toLowerCase();
    return type == 'home' || 
           type == 'casa' || 
           type == 'work' || 
           type == 'trabajo';
  }
}
