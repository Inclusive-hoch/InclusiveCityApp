import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';

class PlaceDetailsModel extends PlaceDetails {
  const PlaceDetailsModel({
    required String placeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> photos,
    required List<String> medals,
    required double rating,
  }) : super(
    placeId: placeId,
    name: name,
    address: address,
    latitude: latitude,
    longitude: longitude,
    photos: photos,
    medals: medals,
    rating: rating,
  );

  // Factory para backend (location-API)
  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    // WORKAROUND: El backend tiene lat/lng invertidos en el constructor de LocationDTO
    // Intercambiamos latitude y longitude para compensar el bug del backend
    return PlaceDetailsModel(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: location['longitude'] as double,  // Invertido: tomamos longitude como latitude
      longitude: location['latitude'] as double,   // Invertido: tomamos latitude como longitude
      photos: List<String>.from(json['photos'] ?? []),
      medals: List<String>.from(json['medals'] ?? []),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}