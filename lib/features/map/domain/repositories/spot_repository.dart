import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';
import 'package:inclusivecity_frontend/features/map/domain/entities/spot_entity.dart';

abstract class SpotRepository {
  /// Guarda un spot del usuario
  /// Returns [Right(SpotEntity)] si tiene éxito
  /// Returns [Left(Failure)] si falla
  Future<Either<Failure, SpotEntity>> saveSpot(SpotEntity spot);

  /// Obtiene todos los spots de un usuario
  /// Returns [Right(List<SpotEntity>)] si tiene éxito
  /// Returns [Left(Failure)] si falla
  Future<Either<Failure, List<SpotEntity>>> getUserSpots(String userId);
}
