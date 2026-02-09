import 'package:equatable/equatable.dart';
import 'package:inclusive_app/features/places/domain/entities/place_details.dart';
import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

/// Estados para el UserEvaluationBloc
abstract class UserEvaluationState extends Equatable {
  const UserEvaluationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class UserEvaluationInitial extends UserEvaluationState {}

/// Estado de carga
class UserEvaluationLoading extends UserEvaluationState {}

/// Estado de éxito con las evaluaciones cargadas
class UserEvaluationLoaded extends UserEvaluationState {
  final List<UserEvaluation> evaluations;
  final Map<String, PlaceDetails> placesDetails;

  const UserEvaluationLoaded(this.evaluations, {this.placesDetails = const {}});

  @override
  List<Object?> get props => [evaluations, placesDetails];
}

/// Estado de error
class UserEvaluationError extends UserEvaluationState {
  final String message;

  const UserEvaluationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado vacío (sin evaluaciones)
class UserEvaluationEmpty extends UserEvaluationState {}