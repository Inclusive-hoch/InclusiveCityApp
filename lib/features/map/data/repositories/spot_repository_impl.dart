import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/exception/exceptions.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/data/datasources/spot_remote_data_source.dart';
import 'package:inclusivecity_frontend/features/map/data/models/spot_model.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/spot_repository.dart';

class SpotRepositoryImpl implements SpotRepository {
  final SpotRemoteDataSource remoteDataSource;

  SpotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SpotEntity>> saveSpot(SpotEntity spot) async {
    try {
      final spotModel = SpotModel(
        id: spot.id,
        userId: spot.userId,
        spotName: spot.spotName,
        placeId: spot.placeId,
        address: spot.address,
        latitude: spot.latitude,
        longitude: spot.longitude,
        type: spot.type,
      );

      final result = await remoteDataSource.saveSpot(spotModel);
      return Right(result.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SpotEntity>>> getUserSpots(String userId) async {
    try {
      final result = await remoteDataSource.getUserSpots(userId);
      return Right(result.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
