import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';
import 'package:inclusivecity_frontend/features/map/domain/repositories/spot_repository.dart';

class SaveSpot {
  final SpotRepository repository;

  SaveSpot(this.repository);

  Future<Either<Failure, SpotEntity>> call(SpotEntity spot) async {
    return await repository.saveSpot(spot);
  }
}
