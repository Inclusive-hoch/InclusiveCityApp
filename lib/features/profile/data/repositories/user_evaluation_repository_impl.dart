import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_remote_datasource.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';
import 'package:inclusive_app/features/profile/domain/repositories/user_evaluation_repository.dart';

/// Implementación del repositorio de evaluaciones del usuario
class UserEvaluationRepositoryImpl implements UserEvaluationRepository {
  final UserEvaluationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserEvaluationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<UserEvaluation>> getUserEvaluations() async {
    if (await networkInfo.isConnected) {
      final evaluations = await remoteDataSource.getUserEvaluations();
      return evaluations;
    } else {
      throw Exception('No hay conexión a internet');
    }
  }
}