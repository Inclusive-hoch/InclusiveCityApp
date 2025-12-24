import 'package:dartz/dartz.dart';

import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';
import 'package:inclusivecity_frontend/core/usecase/usecase.dart';

class SearchPlaces implements UseCase<List<PlaceSuggestion>, String> {
  final PlaceRepository repository;

  SearchPlaces(this.repository);

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> call(String params) async {
    if (params.isEmpty) {
      return const Right([]);
    }
    return await repository.searchPlaces(params);
  }
  

}