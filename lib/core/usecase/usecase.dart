import 'package:dartz/dartz.dart';
import 'package:inclusivecity_frontend/core/error/failure/failure.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class UseCaseWithoutParams<T> {
  Future<Either<Failure, T>> call();
}