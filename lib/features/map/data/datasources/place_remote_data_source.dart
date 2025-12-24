import 'package:inclusivecity_frontend/features/map/data/models/place_detail_model.dart';

import '../models/place_model.dart';

abstract class PlaceRemoteDataSource {
  Future<List<PlaceModel>> getPlaceSuggestions(String query);

  Future<PlaceDetailsModel> getPlaceDetails(String placeId);
  Future<List<PlaceDetailsModel>> getNearbyPlaces(double lat, double lng, int radius);
}