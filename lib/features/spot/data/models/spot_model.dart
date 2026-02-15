import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Modelo de datos para un Spot.
/// 
/// Extiende de [Spot] (entidad de dominio) y agrega funcionalidad
/// para serialización/deserialización JSON y conversión entre capas.
class SpotModel extends Spot {
  const SpotModel({
    required super.userId,
    required super.spotName,
    required super.placeId,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.type,
  });

  /// Crea un [SpotModel] desde un mapa JSON.
  /// 
  /// Extrae las coordenadas del objeto 'location' anidado.
  factory SpotModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;

    return SpotModel(
      userId: json['userId'] as String,
      spotName: json['spotName'] as String,
      placeId: json['placeId'] as String,
      address: json['address'] as String,
      latitude: location?['latitude'] as double? ?? 0.0,
      longitude: location?['longitude'] as double? ?? 0.0,
      type: json['type'] as String?,
    );
  }

  /// Crea un [SpotModel] desde una entidad de dominio [Spot].
  factory SpotModel.fromEntity(Spot spot) {
    return SpotModel(
      userId: spot.userId,
      spotName: spot.spotName,
      placeId: spot.placeId,
      address: spot.address,
      latitude: spot.latitude,
      longitude: spot.longitude,
      type: spot.type,
    );
  }

  /// Convierte el modelo a un mapa JSON.
  /// 
  /// Estructura las coordenadas en un objeto 'location'.
  /// IMPORTANTE: NO incluye userId - se extrae del JWT en el backend.
  Map<String, dynamic> toJson() {
    return {
      'spotName': spotName,
      'placeId': placeId,
      'address': address,
      'location': {'latitude': latitude, 'longitude': longitude},
      if (type != null) 'type': type,
    };
  }

  Spot toEntity() {
    return Spot(
      userId: userId,
      spotName: spotName,
      placeId: placeId,
      address: address,
      latitude: latitude,
      longitude: longitude,
      type: type,
    );
  }
}
