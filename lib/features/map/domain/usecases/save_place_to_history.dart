import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';

class SavePlaceToHistory {
  final PlaceRepository repository;

  SavePlaceToHistory(this.repository);

  Future<Either<Failure, void>> call(PlaceSuggestion place) async {
    return await repository.savePlaceToHistory(place);
  }
}
