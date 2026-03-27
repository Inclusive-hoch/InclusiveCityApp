import 'package:dartz/dartz.dart';
import 'package:inclusive_app/core/errors/exceptions.dart';
import 'package:inclusive_app/features/reviews/data/datasources/review_remote_datasource.dart';
import 'package:inclusive_app/features/reviews/data/models/review_stat_data_request_model.dart';
import 'package:inclusive_app/features/reviews/domain/entities/review_failure.dart';
import 'package:inclusive_app/features/reviews/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  const ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ReviewFailure, Unit>> savePlaceStatData({
    required String placeId,
    required String rateChoice,
    required List<String> forms,
  }) async {
    try {
      await remoteDataSource.savePlaceStatData(
        placeId: placeId,
        request: ReviewStatDataRequestModel(
          rateChoice: rateChoice,
          forms: forms,
        ),
      );
      return const Right(unit);
    } on BadRequestException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 400));
    } on UnauthorizedException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 401));
    } on ForbiddenException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 403));
    } on NotFoundException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 404));
    } on ConflictException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 409));
    } on InternalServerException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: e.statusCode ?? 500));
    } on NetworkException catch (e) {
      return Left(ReviewFailure(e.message));
    } on ServerException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ReviewFailure('Error inesperado al guardar review.'));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> updatePlaceStatData({
    required String placeId,
  }) async {
    try {
      await remoteDataSource.updatePlaceStatData(placeId: placeId);
      return const Right(unit);
    } on BadRequestException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 400));
    } on UnauthorizedException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 401));
    } on ForbiddenException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 403));
    } on NotFoundException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 404));
    } on ConflictException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: 409));
    } on InternalServerException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: e.statusCode ?? 500));
    } on NetworkException catch (e) {
      return Left(ReviewFailure(e.message));
    } on ServerException catch (e) {
      return Left(ReviewFailure(e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(
        ReviewFailure('Error inesperado al actualizar statdata del lugar.'),
      );
    }
  }
}
