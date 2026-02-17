import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa un lugar accesible guardado por el usuario.
/// 
/// Un Spot es un lugar de interés que un usuario ha marcado como relevante,
/// típicamente por su accesibilidad o características inclusivas.
class Spot extends Equatable {
  /// ID del usuario que creó el spot.
  final String userId;
  
  /// Nombre descriptivo del spot.
  final String spotName;
  
  /// ID del lugar en Google Places.
  final String placeId;
  
  /// Dirección completa del lugar.
  final String address;
  
  /// Latitud de la ubicación.
  final double latitude;
  
  /// Longitud de la ubicación.
  final double longitude;
  
  /// Tipo opcional del lugar (ej: 'restaurant', 'hospital').
  final String? type;

  const Spot({
    required this.userId,
    required this.spotName,
    required this.placeId,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
  });

  @override
  List<Object?> get props => [
    userId,
    spotName,
    placeId,
    address,
    latitude,
    longitude,
    type,
  ];
}
