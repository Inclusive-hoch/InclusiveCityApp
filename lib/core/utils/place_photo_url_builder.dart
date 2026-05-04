import 'package:inclusive_app/core/constants/api_constants.dart';

class PlacePhotoUrlBuilder {
  const PlacePhotoUrlBuilder();

  String build(String photoReference) {
    return ApiConstants.placePhoto(photoReference);
  }
}
