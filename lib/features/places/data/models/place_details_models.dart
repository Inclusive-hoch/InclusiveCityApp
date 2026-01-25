import 'package:inclusive_app/features/places/domain/entities/place_details.dart';

class PlaceDetailsModel extends PlaceDetails {
  const PlaceDetailsModel({
    required super.placeId,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.photos,
    required super.medals,
    required super.rating,
  });

  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    // Aviso: El backend tiene lat/lng invertidos en el constructor de LocationDTO
    return PlaceDetailsModel(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: location['longitude'] as double,
      longitude: location['latitude'] as double,
      photos: List<String>.from(json['photos'] ?? []),
      medals: List<String>.from(json['medals'] ?? []),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}
