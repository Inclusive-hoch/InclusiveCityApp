import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_suggestion.dart';


abstract class PlaceRepository {
  Future<Either<Failure, List<PlaceSuggestion>>> searchPlaces(String query);

  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId);

  Future<Either<Failure, List<PlaceDetails>>> getNearbyPlaces(double lat, double lng, {int radius = 5000});

  Future<Either<Failure, List<PlaceSuggestion>>> getSearchHistory();

  Future<Either<Failure, void>> savePlaceToHistory(PlaceSuggestion place);
}

