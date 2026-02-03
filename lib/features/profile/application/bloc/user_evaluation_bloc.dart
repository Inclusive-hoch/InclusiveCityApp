import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_event.dart';
import 'package:inclusive_app/features/profile/application/bloc/user_evaluation_state.dart';
import 'package:inclusive_app/features/profile/domain/usecases/get_user_evaluations.dart';

/// BLoC para gestionar las evaluaciones del usuario
class UserEvaluationBloc extends Bloc<UserEvaluationEvent, UserEvaluationState> {
  final GetUserEvaluations getUserEvaluations;

  UserEvaluationBloc({
    required this.getUserEvaluations,
  }) : super(UserEvaluationInitial()) {
    on<LoadUserEvaluations>(_onLoadUserEvaluations);
    on<RefreshUserEvaluations>(_onRefreshUserEvaluations);
  }

  Future<void> _onLoadUserEvaluations(
    LoadUserEvaluations event,
    Emitter<UserEvaluationState> emit,
  ) async {
    emit(UserEvaluationLoading());
    try {
      final evaluations = await getUserEvaluations();
      if (evaluations.isEmpty) {
        emit(UserEvaluationEmpty());
      } else {
        emit(UserEvaluationLoaded(evaluations));
      }
    } catch (e) {
      emit(UserEvaluationError(e.toString()));
    }
  }

  Future<void> _onRefreshUserEvaluations(
    RefreshUserEvaluations event,
    Emitter<UserEvaluationState> emit,
  ) async {
    try {
      final evaluations = await getUserEvaluations();
      if (evaluations.isEmpty) {
        emit(UserEvaluationEmpty());
      } else {
        emit(UserEvaluationLoaded(evaluations));
      }
    } catch (e) {
      emit(UserEvaluationError(e.toString()));
    }
  }
}