import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';

class PlaceSearchResultModel extends PlaceSearchResult {
  const PlaceSearchResultModel({
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
  factory PlaceSearchResultModel.fromBackendJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    // Aviso: El backend tiene lat/lng invertidos en el constructor de LocationDTO
    return PlaceSearchResultModel(
      placeId: json['placeId'] as String,
      description: json['name'] as String,
      address: json['address'] as String?,
      latitude: location != null ? location['longitude'] as double : null,
      longitude: location != null ? location['latitude'] as double : null,
    );
  }

  // Factory para cache local (SharedPreferences)
  factory PlaceSearchResultModel.fromJson(Map<String, dynamic> json) {
    return PlaceSearchResultModel(
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
