abstract class UserEvaluationEvent {}

// evento para cargar las evaluaciones del usuario
class LoadUserEvaluations extends UserEvaluationEvent {
  final String userId;
  LoadUserEvaluations({required this.userId});
}

//evento para refrescar las evaluaciones del usuario
class RefreshUserEvaluations extends UserEvaluationEvent {
  final String userId;
  RefreshUserEvaluations({required this.userId});
}