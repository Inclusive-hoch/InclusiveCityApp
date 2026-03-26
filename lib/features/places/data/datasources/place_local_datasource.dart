import 'dart:convert';
import 'dart:developer';
import 'package:inclusive_app/features/places/data/models/place_search_result_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';

/// Fuente de datos local para el historial de búsquedas de lugares.
abstract class PlaceLocalDataSource {
  /// Obtiene el historial de búsquedas guardadas.
  Future<List<PlaceSearchResultModel>> getPlaceSearches();
  
  /// Guarda una búsqueda en el historial.
  Future<void> cacheSearch(PlaceSearchResultModel place);
}

const cachedSearchesKey = 'CACHE_SEARCHES';

/// Implementación de [PlaceLocalDataSource] usando SharedPreferences.
/// Mantiene un historial de hasta 3 búsquedas recientes.
class PlaceLocalDataSourceImpl implements PlaceLocalDataSource {
  final SharedPreferences sharedPreferences;

  PlaceLocalDataSourceImpl({required this.sharedPreferences});

  /// Recupera el historial de búsquedas desde caché.
  /// Retorna lista vacía si no hay historial.
  /// Lanza [ServerException] si falla la deserialización.
  @override
  Future<List<PlaceSearchResultModel>> getPlaceSearches() async {
    try {
      final jsonString = sharedPreferences.getString(cachedSearchesKey);

      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        final searches = jsonList
            .map((e) => PlaceSearchResultModel.fromJson(e))
            .toList();

        log('Historial cargado: ${searches.length} busquedas');

        for (var place in searches) {
          log(
            "  - ${place.description}${place.address != null ? ' (${place.address})' : ''}",
          );
        }

        return searches;
      } else {
        log("Historial vacío");
        return <PlaceSearchResultModel>[];
      }
    } catch (e) {
      log("Error al cargar historial: $e");
      throw CacheException('Error al cargar historial');
    }
  }

  /// Guarda una búsqueda en caché, eliminando duplicados.
  /// Mantiene máximo 3 búsquedas, la más reciente primero.
  @override
  Future<void> cacheSearch(PlaceSearchResultModel place) async {
    try {
      List<PlaceSearchResultModel> currentCache = await getPlaceSearches();

      currentCache.removeWhere((element) => element.placeId == place.placeId);

      currentCache.insert(0, place);

      if (currentCache.length > 3) {
        currentCache = currentCache.sublist(0, 3);
      }

      final String jsonString = json.encode(
        currentCache.map((e) => e.toJson()).toList(),
      );
      await sharedPreferences.setString(cachedSearchesKey, jsonString);

      log("Guardado en historial: ${place.description}");
      log("Total en historial: ${currentCache.length}");
    } catch (e) {
      throw CacheException('Error al guardar en historial: $e');
    }
  }
}
