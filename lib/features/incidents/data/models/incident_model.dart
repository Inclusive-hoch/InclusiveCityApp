import '../../domain/entities/incident_entity.dart';

/// Modelo de datos para incidencias.
///
/// Maneja la serialización/deserialización JSON para comunicarse
/// con el backend, y convierte a/desde la entidad de dominio.
class IncidentModel {
  final String type;
  final String subType;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? photoPath;

  IncidentModel({
    required this.type,
    required this.subType,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.photoPath,
  });

  factory IncidentModel.fromEntity(IncidentEntity entity) {
    return IncidentModel(
      type: entity.type,
      subType: entity.subType,
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      photoPath: entity.photoPath,
    );
  }

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      type: json['type'] as String,
      subType: json['sub_type'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      photoPath: json['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sub_type': subType,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      if (photoPath != null) 'photo_path': photoPath,
    };
  }

  IncidentEntity toEntity() => IncidentEntity(
    type: type,
    subType: subType,
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    photoPath: photoPath,
  );
}
