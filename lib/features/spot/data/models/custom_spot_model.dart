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
    // Obtener lista de spots, manejar null y lista vacía
    final spotsJson = json['spots'] as List<dynamic>?;
    final List<SpotModel> parsedSpots = [];
    
    if (spotsJson != null && spotsJson.isNotEmpty) {
      // Obtenemos el userId de la lista (padre) para inyectarlo en los hijos si hacer falta
      final parentUserId = json['userId'] as String? ?? '';

      for (var spotJson in spotsJson) {
        try {
          // Clonamos el mapa para poder modificarlo (algunas veces el map de un JSON es read-only)
          final spotMap = Map<String, dynamic>.from(spotJson as Map);
          
          // Si el spot anidado no trae un userId, inyectamos el userId de la lista
          if (spotMap['userId'] == null) {
            spotMap['userId'] = parentUserId;
          }

          final spot = SpotModel.fromJson(spotMap);
          parsedSpots.add(spot);
        } catch (e) {
          // Si un spot individual falla al parsear, registrar pero continuar
          print('⚠️ [CustomSpotModel] Error parseando spot en lista "${json['listName']}": $e');
        }
      }
    }
    
    return CustomSpotModel(
      id: json['id'] as String?,
      listName: json['listName'] as String,
      userId: json['userId'] as String,
      spotList: parsedSpots,
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
  /// 
  /// IMPORTANTE: NO incluye userId - se extrae del JWT en el backend.
  /// Serializa spotList como 'spots' (nombre que espera el backend).
  Map<String, dynamic> toJson() {
    return {
      'listName': listName,
      'spots': spotList.map((spot) => SpotModel.fromEntity(spot).toJson()).toList(),
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
