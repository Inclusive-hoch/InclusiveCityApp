import 'package:flutter/material.dart';

/// Enum que representa los tipos de medallas de accesibilidad
/// El orden corresponde al índice en el array `forms` de la respuesta del API
enum AccessibilityMedal {
  atencionPreferencial,
  accesibilidad,
  banos,
  // El backend envía duplicado, pero mantenemos el orden
  banosLimpios,
  estacionamiento,
  facilCirculacion,
}

/// Extensión para obtener propiedades de cada medalla
extension AccessibilityMedalExtension on AccessibilityMedal {
  /// Nombre del enum tal como viene del backend
  String get apiName {
    switch (this) {
      case AccessibilityMedal.atencionPreferencial:
        return 'ATENCION_PREFERENCIAL';
      case AccessibilityMedal.accesibilidad:
        return 'ACCESIBILIDAD';
      case AccessibilityMedal.banos:
        return 'BANOS';
      case AccessibilityMedal.banosLimpios:
        return 'BANOS';
      case AccessibilityMedal.estacionamiento:
        return 'ESTACIONAMIENTO';
      case AccessibilityMedal.facilCirculacion:
        return 'FACIL_CIRCULACION';
    }
  }

  /// Nombre legible para mostrar al usuario
  String get displayName {
    switch (this) {
      case AccessibilityMedal.atencionPreferencial:
        return 'Atención Preferencial';
      case AccessibilityMedal.accesibilidad:
        return 'Accesibilidad';
      case AccessibilityMedal.banos:
        return 'Baños';
      case AccessibilityMedal.banosLimpios:
        return 'Baños Limpios';
      case AccessibilityMedal.estacionamiento:
        return 'Estacionamiento';
      case AccessibilityMedal.facilCirculacion:
        return 'Fácil Circulación';
    }
  }

  /// Icono correspondiente a cada medalla
  IconData get icon {
    switch (this) {
      case AccessibilityMedal.atencionPreferencial:
        return Icons.support_agent;
      case AccessibilityMedal.accesibilidad:
        return Icons.accessible;
      case AccessibilityMedal.banos:
        return Icons.wc;
      case AccessibilityMedal.banosLimpios:
        return Icons.wc;
      case AccessibilityMedal.estacionamiento:
        return Icons.e_mobiledata;
      case AccessibilityMedal.facilCirculacion:
        return Icons.directions_walk;
    }
  }

  /// Letra abreviada para mostrar en caso de no usar icono
  String get abbreviation {
    switch (this) {
      case AccessibilityMedal.atencionPreferencial:
        return 'A';
      case AccessibilityMedal.accesibilidad:
        return 'AC';
      case AccessibilityMedal.banos:
        return 'B';
      case AccessibilityMedal.banosLimpios:
        return 'BL';
      case AccessibilityMedal.estacionamiento:
        return 'E';
      case AccessibilityMedal.facilCirculacion:
        return 'FC';
    }
  }
}

/// Clase helper para trabajar con medallas de accesibilidad
class AccessibilityMedalsHelper {
  /// Lista ordenada de medallas según el backend (orden igual al array forms)
  static const List<AccessibilityMedal> orderedMedals = AccessibilityMedal.values;

  /// Lista de medallas visibles en la UI (5 en total, sin duplicar baños)
  static const List<AccessibilityMedal> visibleMedals = [
    AccessibilityMedal.atencionPreferencial,
    AccessibilityMedal.accesibilidad,
    AccessibilityMedal.banos,
    AccessibilityMedal.estacionamiento,
    AccessibilityMedal.facilCirculacion,
  ];

  /// Obtiene las medallas confirmadas basado en el array de forms
  /// Retorna una lista de medallas donde forms[i] == "YES"
  static List<AccessibilityMedal> getConfirmedMedals(List<String> forms) {
    final confirmed = <AccessibilityMedal>[];
    for (var i = 0; i < forms.length && i < orderedMedals.length; i++) {
      final medal = orderedMedals[i];
      if (!visibleMedals.contains(medal)) {
        continue;
      }

      if (forms[i].toUpperCase() == 'YES') {
        confirmed.add(medal);
      }
    }
    return confirmed;
  }

  /// Obtiene la medalla desde el nombre del API
  static AccessibilityMedal? fromApiName(String apiName) {
    for (final medal in AccessibilityMedal.values) {
      if (medal.apiName == apiName) {
        return medal;
      }
    }
    return null;
  }
}
