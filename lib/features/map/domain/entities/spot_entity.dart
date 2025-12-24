import 'package:equatable/equatable.dart';

class SpotEntity extends Equatable {
  final String? id;
  final String userId;
  final String spotName;
  final String placeId;
  final String address;
  final double latitude;
  final double longitude;
  final String? type;

  const SpotEntity({
    this.id,
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
        id,
        userId,
        spotName,
        placeId,
        address,
        latitude,
        longitude,
        type,
      ];
}
