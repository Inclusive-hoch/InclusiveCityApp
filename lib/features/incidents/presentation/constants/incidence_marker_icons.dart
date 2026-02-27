import 'package:flutter/material.dart';

/// Mapeo de nombres de incidencia del backend a iconos de Material.
///
/// Los nombres del backend vienen en formato uppercase (ej: "ILUMINACION"),
/// y se mapean a los iconos ya definidos en los subtipos de incidencias
/// de la presentación.
const Map<String, IconData> incidenceBackendIcons = {
  // Veredas y superficies
  'GRIETAS': Icons.foundation,
  'BACHES': Icons.dangerous,
  'DESNIVELES': Icons.signal_cellular_0_bar,
  'SUPERFICIE_RESBALADIZA': Icons.severe_cold,

  // Cruces peatonales
  'FALTA_DE_REBAJE': Icons.height,
  'SEMAFORO_SIN_SENAL_AUDITIVA': Icons.hearing_disabled,

  // Problemas temporales
  'ILUMINACION': Icons.lightbulb_outline,
  'OBRA': Icons.engineering,
  'ESCOMBROS': Icons.delete_sweep,
  'BLOQUEO_DE_RUTA': Icons.block,

  // Rampas
  'FALTA_DE_RAMPA': Icons.not_accessible,
  'RAMPA_DANADA': Icons.report_problem,
  'RAMPA_BLOQUEADA': Icons.do_not_step,
};

/// Ícono por defecto cuando el tipo de incidencia no se reconoce.
const IconData defaultIncidenceIcon = Icons.warning_amber;

/// Retorna el ícono asociado a un nombre de incidencia del backend.
IconData getIncidenceIcon(String backendName) {
  return incidenceBackendIcons[backendName.toUpperCase()] ??
      defaultIncidenceIcon;
}
