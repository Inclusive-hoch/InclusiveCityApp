import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:inclusive_app/features/reviews/domain/entities/review_failure.dart';
import 'package:inclusive_app/features/reviews/domain/repositories/review_repository.dart';

class SavePlaceRateChoiceUseCase {
  final ReviewRepository repository;

  const SavePlaceRateChoiceUseCase(this.repository);

  Future<Either<ReviewFailure, Unit>> call(
    SavePlaceRateChoiceParams params,
  ) async {
    final saveResult = await repository.savePlaceRateChoice(
      placeId: params.placeId,
      rateChoice: params.rateChoice,
    );

    return saveResult.fold(
      Left.new,
      (_) => repository.updatePlaceStatData(placeId: params.placeId),
    );
  }
}

class SavePlaceRateChoiceParams extends Equatable {
  final String placeId;
  final String rateChoice;

  const SavePlaceRateChoiceParams({
    required this.placeId,
    required this.rateChoice,
  });

  @override
  List<Object> get props => [placeId, rateChoice];
}
