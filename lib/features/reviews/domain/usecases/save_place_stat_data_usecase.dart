import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:inclusive_app/features/reviews/domain/entities/review_failure.dart';
import 'package:inclusive_app/features/reviews/domain/repositories/review_repository.dart';

class SavePlaceStatDataUseCase {
  final ReviewRepository repository;

  const SavePlaceStatDataUseCase(this.repository);

  Future<Either<ReviewFailure, Unit>> call(SavePlaceStatDataParams params) async {
    final saveResult = await repository.savePlaceStatData(
      placeId: params.placeId,
      forms: params.forms,
    );

    return saveResult.fold(
      Left.new,
      (_) => repository.updatePlaceStatData(placeId: params.placeId),
    );
  }
}

class SavePlaceStatDataParams extends Equatable {
  final String placeId;
  final List<String> forms;

  const SavePlaceStatDataParams({
    required this.placeId,
    required this.forms,
  });

  @override
  List<Object> get props => [placeId, forms];
}
