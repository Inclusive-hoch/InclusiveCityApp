abstract class UserEvaluationEvent {}

// evento para cargar las evaluaciones del usuario
class LoadUserEvaluations extends UserEvaluationEvent {
  final String userId;
  final bool forceRefresh;

  LoadUserEvaluations({required this.userId, this.forceRefresh = false});
}

//evento para refrescar las evaluaciones del usuario
class RefreshUserEvaluations extends UserEvaluationEvent {
  final String userId;
  RefreshUserEvaluations({required this.userId});
}