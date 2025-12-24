import 'package:equatable/equatable.dart';

class PlaceSuggestion extends Equatable {
  final String placeId;
  final String description;
  final String? address; // Dirección del lugar
  final double? latitude;
  final double? longitude;
  
  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [placeId, description, address, latitude, longitude];
}