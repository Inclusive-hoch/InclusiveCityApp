import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';

class SavePlaceToHistory {
  final PlaceRepository repository;

  SavePlaceToHistory(this.repository);

  Future<void> call(PlaceSearchResult place) async {
    return await repository.savePlaceToHistory(place);
  }
}
