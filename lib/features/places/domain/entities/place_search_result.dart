import 'package:equatable/equatable.dart';

class PlaceSearchResult extends Equatable {
  final String placeId;
  final String description;
  final String? address;
  final double? latitude;
  final double? longitude;

  const PlaceSearchResult({
    required this.placeId,
    required this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    placeId,
    description,
    address,
    latitude,
    longitude,
  ];
}
