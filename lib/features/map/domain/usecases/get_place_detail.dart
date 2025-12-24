// lib/features/map/domain/usecases/get_place_details.dart
import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/place_details.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/place_repository.dart';

class GetPlaceDetails {
  final PlaceRepository repository;

  GetPlaceDetails(this.repository);

  Future<Either<Failure, PlaceDetails>> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}