import 'package:inclusive_app/features/places/domain/entities/place_details.dart';
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';

abstract class PlaceRepository {
  Future<List<PlaceSearchResult>> searchPlaces(String query);

  Future<PlaceDetails> getPlaceDetails(String placeId);

  Future<List<PlaceSearchResult>> getSearchHistory();

  Future<void> savePlaceToHistory(PlaceSearchResult place);
}
