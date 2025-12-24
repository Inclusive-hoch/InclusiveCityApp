import 'dart:convert';
import 'package:inclusivecity_frontend/core/error/exception/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inclusivecity_frontend/features/map/data/models/place_model.dart';

abstract class PlaceLocalDataSource {
  Future<List<PlaceModel>> getLastSearches();
  Future<void> cacheSearch(PlaceModel place);
}

const CACHED_SEARCHES_KEY = 'CACHED_SEARCHES';

class PlaceLocalDataSourceImpl implements PlaceLocalDataSource {
  final SharedPreferences sharedPreferences;

  PlaceLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PlaceModel>> getLastSearches() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_SEARCHES_KEY);
      if (jsonString != null) {
        List<dynamic> jsonList = json.decode(jsonString);
        final searches = jsonList.map((e) => PlaceModel.fromJson(e)).toList();
        print("Historial cargado: ${searches.length} búsquedas");
        for (var place in searches) {
          print("  - ${place.description}${place.address != null ? ' (${place.address})' : ''}");
        }
        return searches;
      } else {
        print("Historial vacío");
        return [];
      }
    } catch (e) {
      print("Error al cargar historial: $e");
      return [];
    }
  }

  @override
  Future<void> cacheSearch(PlaceModel place) async {
    try {
      List<PlaceModel> currentCache = await getLastSearches();
      
      currentCache.removeWhere((element) => element.placeId == place.placeId);
      
      currentCache.insert(0, place);
      
      if (currentCache.length > 3) {
        currentCache = currentCache.sublist(0, 3);
      }

      final String jsonString = json.encode(currentCache.map((e) => e.toJson()).toList());
      await sharedPreferences.setString(CACHED_SEARCHES_KEY, jsonString);
      
      print("Guardado en historial: ${place.description}");
      print("Total en historial: ${currentCache.length}");
    } catch (e) {
      print("Error al guardar en historial: $e");
      throw CacheException();
    }
  }
}