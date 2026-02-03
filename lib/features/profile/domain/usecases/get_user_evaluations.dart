import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';
import 'package:inclusive_app/features/profile/domain/repositories/user_evaluation_repository.dart';
// Caso de uso para obtener las evaluaciones del usuario
class GetUserEvaluations {
  final UserEvaluationRepository repository;

  GetUserEvaluations(this.repository);

  Future<List<UserEvaluation>> call() async{
    return await repository.getUserEvaluations();
  }
}