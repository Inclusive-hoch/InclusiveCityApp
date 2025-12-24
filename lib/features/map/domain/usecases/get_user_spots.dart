import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/spot_repository.dart';

class GetUserSpots {
  final SpotRepository repository;

  GetUserSpots(this.repository);

  Future<Either<Failure, List<SpotEntity>>> call(String userId) async {
    return await repository.getUserSpots(userId);
  }
}
