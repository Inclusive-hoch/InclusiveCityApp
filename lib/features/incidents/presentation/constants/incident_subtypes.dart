import 'package:flutter/material.dart';

/// Clase que representa un subtipo de incidente con su icono
class IncidentSubType {
  final String name;
  final IconData icon;

  const IncidentSubType({required this.name, required this.icon});
}

/// Mapa de subtipos de incidencias por tipo principal
const Map<String, List<IncidentSubType>> incidentSubTypes = {
  'Transporte': [
    IncidentSubType(name: 'Accidente', icon: Icons.car_crash),
    IncidentSubType(name: 'Corte de vía', icon: Icons.block),
    IncidentSubType(name: 'Retraso', icon: Icons.access_time),
  ],
  'Accesibilidad': [
    IncidentSubType(name: 'Escalera rota', icon: Icons.stairs),
    IncidentSubType(name: 'Ascensor fuera de servicio', icon: Icons.elevator),
  ],
  'Movilidad': [
    IncidentSubType(name: 'Vereda dañada', icon: Icons.warning),
    IncidentSubType(name: 'Rampa bloqueada', icon: Icons.accessible),
  ],
};
