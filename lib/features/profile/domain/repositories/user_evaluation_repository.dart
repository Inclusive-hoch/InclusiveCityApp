import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';
// Repositorio abstracto para las evaluaciones del usuario
abstract class UserEvaluationRepository {
  // Obtiene todas las evaluaciones realizadas por el usuario
  Future<List<UserEvaluation>> getUserEvaluations(
    String userId, {
    bool forceRefresh = false,
  });
}