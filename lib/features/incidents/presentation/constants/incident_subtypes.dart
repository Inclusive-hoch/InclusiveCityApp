import 'package:flutter/material.dart';

/// Clase que representa un subtipo de incidente con su icono
class IncidentSubType {
  final String name;
  final IconData icon;

  const IncidentSubType({required this.name, required this.icon});
}

/// Mapa de subtipos de incidencias por tipo principal
const Map<String, List<IncidentSubType>> incidentSubTypes = {
  'Veredas y superficies': [
    IncidentSubType(name: 'Grietas', icon: Icons.foundation),
    IncidentSubType(name: 'Baches', icon: Icons.dangerous),
    IncidentSubType(name: 'Desniveles', icon: Icons.signal_cellular_0_bar),
    IncidentSubType(name: 'Superficie resbaladiza', icon: Icons.severe_cold),
  ],
  'Cruces peatonales': [
    IncidentSubType(name: 'Falta de rebaje', icon: Icons.height),
    IncidentSubType(
      name: 'Semáforo sin señal auditiva',
      icon: Icons.hearing_disabled,
    ),
  ],
  'Problemas temporales': [
    IncidentSubType(
      name: 'Problema alumbrado público',
      icon: Icons.lightbulb_outline,
    ),
    IncidentSubType(name: 'Obra', icon: Icons.engineering),
    IncidentSubType(name: 'Escombros', icon: Icons.delete_sweep),
    IncidentSubType(name: 'Bloqueo de ruta', icon: Icons.block),
  ],
  'Rampas': [
    IncidentSubType(name: 'Falta de rampa', icon: Icons.not_accessible),
    IncidentSubType(name: 'Rampa dañada', icon: Icons.report_problem),
    IncidentSubType(name: 'Rampa bloqueada', icon: Icons.do_not_step),
  ],
};
