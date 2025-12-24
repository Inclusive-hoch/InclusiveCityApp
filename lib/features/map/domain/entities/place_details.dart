import 'package:equatable/equatable.dart';

class PlaceDetails extends Equatable {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> photos;        
  final List<String> medals;       
  final double rating;              

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.medals,
    required this.rating,
  });

  @override
  List<Object?> get props => [placeId, name, address, latitude, longitude, photos, medals, rating];
}