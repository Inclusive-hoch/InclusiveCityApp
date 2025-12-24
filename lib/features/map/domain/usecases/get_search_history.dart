import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';

class GetSearchHistory {
  final PlaceRepository repository;

  GetSearchHistory(this.repository);

  Future<Either<Failure, List<PlaceSuggestion>>> call() async {
    return await repository.getSearchHistory();
  }
}
