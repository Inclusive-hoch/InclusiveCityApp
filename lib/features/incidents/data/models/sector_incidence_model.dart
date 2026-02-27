import '../../domain/entities/sector_incidence_entity.dart';

/// Modelo de datos para incidencias de sector.
///
/// Maneja la deserialización JSON de la respuesta del endpoint
/// `/location/incidence/sector` y convierte a la entidad de dominio.
class SectorIncidenceModel {
  final String placeId;
  final String incidence;
  final DateTime expiresAt;
  final String userId;
  final String? image;
  final double latitude;
  final double longitude;

  SectorIncidenceModel({
    required this.placeId,
    required this.incidence,
    required this.expiresAt,
    required this.userId,
    this.image,
    required this.latitude,
    required this.longitude,
  });

  factory SectorIncidenceModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    return SectorIncidenceModel(
      placeId: json['placeId'] as String,
      incidence: json['incidence'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      image: json['image'] as String?,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
    );
  }

  SectorIncidenceEntity toEntity() => SectorIncidenceEntity(
    placeId: placeId,
    incidence: incidence,
    expiresAt: expiresAt,
    userId: userId,
    image: image,
    latitude: latitude,
    longitude: longitude,
  );
}
