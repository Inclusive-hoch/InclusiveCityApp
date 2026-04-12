import 'package:dartz/dartz.dart';
import 'package:inclusive_app/features/reviews/domain/entities/review_failure.dart';

abstract class ReviewRepository {
  Future<Either<ReviewFailure, Unit>> savePlaceRateChoice({
    required String placeId,
    required String rateChoice,
  });

  Future<Either<ReviewFailure, Unit>> savePlaceStatData({
    required String placeId,
    required List<String> forms,
  });

  Future<Either<ReviewFailure, Unit>> updatePlaceStatData({
    required String placeId,
  });
}
