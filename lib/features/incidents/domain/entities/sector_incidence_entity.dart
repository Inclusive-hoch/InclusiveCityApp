/// Entidad de dominio que representa una incidencia registrada en un sector del mapa.
///
/// Contiene la información necesaria para visualizar una incidencia
/// como marker en el mapa.
class SectorIncidenceEntity {
  final String placeId;
  final String incidence;
  final DateTime expiresAt;
  final String userId;
  final String? image;
  final double latitude;
  final double longitude;

  const SectorIncidenceEntity({
    required this.placeId,
    required this.incidence,
    required this.expiresAt,
    required this.userId,
    this.image,
    required this.latitude,
    required this.longitude,
  });
}
