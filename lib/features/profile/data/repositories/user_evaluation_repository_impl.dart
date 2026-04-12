import 'package:inclusive_app/core/network/network_info.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_local_datasource.dart';
import 'package:inclusive_app/features/profile/data/datasources/user_evaluation_remote_datasource.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';
import 'package:inclusive_app/features/profile/domain/repositories/user_evaluation_repository.dart';

/// Implementación del repositorio de evaluaciones del usuario
class UserEvaluationRepositoryImpl implements UserEvaluationRepository {
  final UserEvaluationRemoteDataSource remoteDataSource;
  final UserEvaluationLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  UserEvaluationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<List<UserEvaluation>> getUserEvaluations(
    String userId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      try {
        final lastUpdate = await localDatasource.getLastUpdate(userId);

        if (lastUpdate != null) {
          final cacheValid =
              DateTime.now().difference(lastUpdate) < const Duration(hours: 6);

          if (cacheValid) {
            final cachedEvaluations = await localDatasource.getCachedEvaluations(
              userId,
            );
            if (cachedEvaluations.isNotEmpty) {
              return cachedEvaluations;
            }
          }
        }
      } catch (_) {}
    }

    if (await networkInfo.isConnected) {
      try {
        final evaluations = await remoteDataSource.getUserEvaluations(userId);
        await localDatasource.cacheEvaluations(userId, evaluations);
        return evaluations;
      } catch (_) {
        try {
          final cachedEvaluations = await localDatasource.getCachedEvaluations(
            userId,
          );
          if (cachedEvaluations.isNotEmpty) {
            return cachedEvaluations;
          }
        } catch (_) {}

        throw Exception('Error al obtener los datos');
      }
    } else {
      try {
        final oldCachedEvaluations = await localDatasource.getCachedEvaluations(
          userId,
        );
        if (oldCachedEvaluations.isNotEmpty) {
          return oldCachedEvaluations;
        }
      } catch (_) {}
      
      throw Exception('No hay conexión a internet y no hay datos guardados');
    }
  }
}
