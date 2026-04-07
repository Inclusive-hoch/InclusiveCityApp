import 'package:flutter/material.dart';

/// Mapeo de nombres de incidencia del backend a iconos de Material.
///
/// Los nombres del backend vienen en formato uppercase (ej: "ALUMBRADO_PUBLICO"),
/// y se mapean a los iconos ya definidos en los subtipos de incidencias
/// de la presentación.
const Map<String, IconData> incidenceBackendIcons = {
  // Veredas y superficies
  'GRIETAS': Icons.foundation,
  'BACHES': Icons.dangerous,
  'DESNIVELES': Icons.signal_cellular_0_bar,
  'SUPERFICIE_RESBALADIZA': Icons.severe_cold,

  // Cruces peatonales
  'FALTA_REBAJE': Icons.height,
  'FALTA_DE_REBAJE': Icons.height,
  'SEMAFORO_MUTE': Icons.hearing_disabled,
  'SEMAFORO_SIN_SENAL_AUDITIVA': Icons.hearing_disabled,

  // Problemas temporales
  'ALUMBRADO_PUBLICO': Icons.lightbulb_outline,
  'ILUMINACION': Icons.lightbulb_outline,
  'OBRA': Icons.engineering,
  'ESCOMBROS': Icons.delete_sweep,
  'BLOQUEDO_RUTA': Icons.block,
  'BLOQUEO_DE_RUTA': Icons.block,

  // Rampas
  'NO_RAMPA': Icons.not_accessible,
  'FALTA_DE_RAMPA': Icons.not_accessible,
  'RAMPA_DANADA': Icons.report_problem,
  'RAMPA_BLOQUEADA': Icons.do_not_step,
};

/// Ícono por defecto cuando el tipo de incidencia no se reconoce.
const IconData defaultIncidenceIcon = Icons.warning_amber;

/// Mapeo de nombres de incidencia (backend o UI) a etiquetas legibles.
const Map<String, String> incidenceDisplayNames = {
  // Veredas y superficies
  'GRIETAS': 'Grietas',
  'BACHES': 'Baches',
  'DESNIVELES': 'Desniveles',
  'SUPERFICIE_RESBALADIZA': 'Superficie resbaladiza',

  // Cruces peatonales
  'FALTA_REBAJE': 'Falta de rebaje',
  'FALTA_DE_REBAJE': 'Falta de rebaje',
  'SEMAFORO_MUTE': 'Semáforo sin señal auditiva',
  'SEMAFORO_SIN_SENAL_AUDITIVA': 'Semáforo sin señal auditiva',

  // Problemas temporales
  'ALUMBRADO_PUBLICO': 'Problema alumbrado público',
  'ILUMINACION': 'Problema alumbrado público',
  'OBRA': 'Obra',
  'ESCOMBROS': 'Escombros',
  'BLOQUEDO_RUTA': 'Bloqueo de ruta',
  'BLOQUEO_DE_RUTA': 'Bloqueo de ruta',

  // Rampas
  'NO_RAMPA': 'Falta de rampa',
  'FALTA_DE_RAMPA': 'Falta de rampa',
  'RAMPA_DANADA': 'Rampa dañada',
  'RAMPA_BLOQUEADA': 'Rampa bloqueada',
};

/// Retorna el ícono asociado a un nombre de incidencia del backend.
IconData getIncidenceIcon(String backendName) {
  return incidenceBackendIcons[backendName.toUpperCase()] ??
      defaultIncidenceIcon;
}

/// Retorna una etiqueta legible para mostrar en UI.
String getIncidenceDisplayName(String incidenceName) {
  final normalized = incidenceName.trim().toUpperCase();
  final mapped = incidenceDisplayNames[normalized];
  if (mapped != null) return mapped;

  return incidenceName
      .trim()
      .replaceAll('_', ' ')
      .toLowerCase()
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}
