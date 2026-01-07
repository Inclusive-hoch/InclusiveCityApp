import 'package:inclusive_app/features/places/domain/repositories/place_repository.dart';
import 'package:inclusive_app/features/places/domain/entities/place_details.dart';

class GetPlaceDetails {
  final PlaceRepository repository;

  GetPlaceDetails(this.repository);

  Future <PlaceDetails> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}