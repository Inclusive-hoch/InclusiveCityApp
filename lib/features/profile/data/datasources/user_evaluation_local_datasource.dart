import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

abstract class UserEvaluationLocalDatasource {
  //Obtiene la lista de evaluaciones guardadas en el telefono
  Future<List<UserEvaluation>> getCachedEvaluations(String userId);

  //Guarda una nueva lista de evaluaciones en el telefono
  Future<void> cacheEvaluations(String userId, List<UserEvaluation> evaluations);

  //Obtiene la fecha y hora de los ultimos datos guardados
  Future<DateTime?> getLastUpdate(String userId);
}