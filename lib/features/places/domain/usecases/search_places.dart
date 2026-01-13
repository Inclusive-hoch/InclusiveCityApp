
import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';

class SearchPlaces{
  final PlaceRepository repository;

  SearchPlaces(this.repository);

  Future<List<PlaceSearchResult>> call(String params) async {
    if (params.isEmpty) {
      return [];
    }
    return await repository.searchPlaces(params);
  }
  

}