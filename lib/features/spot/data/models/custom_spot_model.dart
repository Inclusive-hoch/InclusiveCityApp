import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'spot_model.dart';

/// Modelo de datos para una lista personalizada de spots.
/// 
/// Extiende de [CustomSpot] (entidad de dominio) y agrega funcionalidad
/// para serialización/deserialización JSON y conversión entre capas.
class CustomSpotModel extends CustomSpot {
  const CustomSpotModel({
    super.id,
    required super.listName,
    required super.userId,
    required super.spotList,
  });

  /// Crea un [CustomSpotModel] desde un mapa JSON.
  /// 
  /// Deserializa la lista de spots desde el campo 'spots'.
  factory CustomSpotModel.fromJson(Map<String, dynamic> json) {
    return CustomSpotModel(
      id: json['id'] as String?,
      listName: json['listName'] as String,
      userId: json['userId'] as String,
      spotList: (json['spots'] as List<dynamic>)
          .map((spot) => SpotModel.fromJson(spot as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Crea un [CustomSpotModel] desde una entidad de dominio [CustomSpot].
  factory CustomSpotModel.fromEntity(CustomSpot customSpot) {
    return CustomSpotModel(
      id: customSpot.id,
      listName: customSpot.listName,
      userId: customSpot.userId,
      spotList: customSpot.spotList,
    );
  }

  /// Convierte el modelo a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listName': listName,
      'userId': userId,
      'spotList': spotList,
    };
  }

  /// Convierte el modelo a una entidad de dominio [CustomSpot].
  CustomSpot toEntity() {
    return CustomSpot(
      id:id,
      listName:listName,
      userId: userId,
      spotList: spotList
    );
  }
}
