abstract class UserEvaluationEvent {}

// evento para cargar las evaluaciones del usuario
class LoadUserEvaluations extends UserEvaluationEvent{}

//evento para refrescar las evaluaciones del usuario
class RefreshUserEvaluations extends UserEvaluationEvent{}