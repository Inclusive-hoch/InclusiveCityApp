import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';

class SpotModel extends SpotEntity {
  const SpotModel({
    super.id,
    required super.userId,
    required super.spotName,
    required super.placeId,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.type,
  });

  factory SpotModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    
    return SpotModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      spotName: json['spotName'] as String,
      placeId: json['placeId'] as String,
      address: json['address'] as String,
      latitude: location?['latitude'] as double? ?? 0.0,
      longitude: location?['longitude'] as double? ?? 0.0,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'spotName': spotName,
      'placeId': placeId,
      'address': address,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
      if (type != null) 'type': type,
    };
  }

  SpotEntity toEntity() {
    return SpotEntity(
      id: id,
      userId: userId,
      spotName: spotName,
      placeId: placeId,
      address: address,
      latitude: latitude,
      longitude: longitude,
      type: type,
    );
  }
}
