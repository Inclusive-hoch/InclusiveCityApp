import 'package:inclusive_app/features/places/domain/entities/place_search_result.dart';
import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';

class GetSearchHistory {
  final PlaceRepository repository;

  GetSearchHistory(this.repository);

  Future<List<PlaceSearchResult>> call() async {
    return await repository.getSearchHistory();
  }
}
