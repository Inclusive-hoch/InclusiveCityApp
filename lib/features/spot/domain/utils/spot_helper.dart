import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Helper con utilidades para validación y creación de spots.
/// 
/// Contiene lógica de negocio reutilizable relacionada con spots:
/// - Validación de coordenadas
/// - Detección de tipo de lugar
/// - Creación de entidades Spot
class SpotHelper {
  SpotHelper._();

  /// Valida que las coordenadas sean válidas y no nulas.
  /// 
  /// Retorna un mensaje de error si las coordenadas son inválidas,
  /// o null si son válidas.
  static String? validateCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return 'Este lugar no tiene coordenadas. Por favor selecciona otro lugar.';
    }

    if (latitude == 0.0 && longitude == 0.0) {
      return 'Las coordenadas del lugar son inválidas. Por favor intenta con otro lugar.';
    }

    return null; // Coordenadas válidas
  }

  /// Detecta el tipo de lugar basándose en el nombre.
  /// 
  /// Retorna:
  /// - 'home' si el nombre contiene casa/home
  /// - 'work' si el nombre contiene trabajo/work/oficina
  /// - null para otros casos
  static String? detectPlaceType(String name) {
    final nameLower = name.toLowerCase();

    if (nameLower.contains('casa') || nameLower.contains('home')) {
      return 'home';
    }

    if (nameLower.contains('trabajo') ||
        nameLower.contains('work') ||
        nameLower.contains('oficina')) {
      return 'work';
    }

    return null;
  }

  /// Crea una entidad Spot desde un PlaceSearchResult y nombre personalizado.
  /// 
  /// Lanza [ArgumentError] si las coordenadas son inválidas.
  /// 
  /// Si se proporciona [type], se usará ese tipo en lugar de detectarlo automáticamente.
  static Spot createSpotFromPlace({
    required PlaceSearchResult place,
    required String name,
    required String userId,
    String? type,
  }) {
    final lat = place.latitude;
    final lng = place.longitude;

    // Validar coordenadas
    final validationError = validateCoordinates(lat, lng);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return Spot(
      userId: userId,
      spotName: name,
      placeId: place.placeId,
      address: place.address ?? place.description,
      latitude: lat!,
      longitude: lng!,
      type: type ?? detectPlaceType(name), // Usar tipo proporcionado o detectar
    );
  }
}
