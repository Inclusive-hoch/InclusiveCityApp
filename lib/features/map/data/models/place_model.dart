import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';

class PlaceModel extends PlaceSuggestion {
  const PlaceModel({
    required String placeId,
    required String description,
    String? address,
    double? latitude,
    double? longitude,
  }) : super(
    placeId: placeId, 
    description: description,
    address: address,
    latitude: latitude,
    longitude: longitude,
  );

  // Factory para backend (location-API)
  factory PlaceModel.fromBackendJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    // WORKAROUND: El backend tiene lat/lng invertidos en el constructor de LocationDTO
    return PlaceModel(
      placeId: json['placeId'] as String,
      description: json['name'] as String,
      address: json['address'] as String?,
      latitude: location != null ? location['longitude'] as double : null,  // Invertido
      longitude: location != null ? location['latitude'] as double : null,   // Invertido
    );
  }

  // Factory para cache local (SharedPreferences)
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      placeId: json['placeId'] as String,
      description: json['description'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  // Serialización para cache local
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}