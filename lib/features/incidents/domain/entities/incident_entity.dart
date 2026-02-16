/// Entidad de dominio que representa una incidencia reportada.
class IncidentEntity {
  final String type;
  final String subType;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? photoPath;

  const IncidentEntity({
    required this.type,
    required this.subType,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.photoPath,
  });
}
