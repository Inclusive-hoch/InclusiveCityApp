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
  /// Lanza [FormatException] si los datos son inválidos.
  factory SpotModel.fromJson(Map<String, dynamic> json) {
    // Validar campos requeridos
    if (json['userId'] == null) {
      throw FormatException('SpotModel.fromJson: userId es null');
    }
    if (json['spotName'] == null) {
      throw FormatException('SpotModel.fromJson: spotName es null');
    }
    if (json['placeId'] == null) {
      throw FormatException('SpotModel.fromJson: placeId es null');
    }
    if (json['address'] == null) {
      throw FormatException('SpotModel.fromJson: address es null');
    }

    final location = json['location'] as Map<String, dynamic>?;
    
    // Validar coordenadas
    if (location == null) {
      throw FormatException('SpotModel.fromJson: location es null para spot "${json['spotName']}"');
    }
    
    final latitude = location['latitude'] as double?;
    final longitude = location['longitude'] as double?;
    
    if (latitude == null || longitude == null) {
      throw FormatException('SpotModel.fromJson: coordenadas null para spot "${json['spotName']}" (lat: $latitude, lng: $longitude)');
    }
    
    if (latitude == 0.0 && longitude == 0.0) {
      throw FormatException('SpotModel.fromJson: coordenadas inválidas (0.0, 0.0) para spot "${json['spotName']}"');
    }

    return SpotModel(
      userId: json['userId'] as String,
      spotName: json['spotName'] as String,
      placeId: json['placeId'] as String,
      address: json['address'] as String,
      latitude: latitude,
      longitude: longitude,
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
  /// El campo 'type' siempre se incluye, con default 'other' si es null.
  Map<String, dynamic> toJson() {
    return {
      'spotName': spotName,
      'placeId': placeId,
      'address': address,
      'location': {'latitude': latitude, 'longitude': longitude},
      'type': type ?? 'other',  // Backend requiere este campo siempre
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
