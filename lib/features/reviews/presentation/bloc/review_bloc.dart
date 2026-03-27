import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/features/reviews/domain/usecases/save_place_stat_data_usecase.dart';
import '../../domain/entities/review_category.dart';
import '../../domain/entities/review_question.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SavePlaceStatDataUseCase savePlaceStatDataUseCase;

  ReviewBloc({required this.savePlaceStatDataUseCase})
    : super(ReviewState(questions: _globalQuestions)) {
    on<ReviewCategorySelected>(_onCategorySelected);
    on<ReviewQuestionAnswered>(_onQuestionAnswered);
    on<ReviewBackRequested>(_onBackRequested);
    on<ReviewRateChoiceChanged>(_onRateChoiceChanged);
    on<ReviewSubmitRequested>(_onSubmitRequested);
    on<ReviewNextRequested>(_onNextRequested);
    on<ReviewReset>(_onReset);
  }

  static const List<ReviewQuestion> _globalQuestions = [
    ReviewQuestion(
      id: '1',
      category: ReviewCategory.preferentialAttention,
      question: '¿Existe atencion preferencial para personas que lo requieran?',
    ),
    ReviewQuestion(
      id: '2',
      category: ReviewCategory.accessibility,
      question: '¿El acceso al establecimiento es facil para todas las personas?',
    ),
    ReviewQuestion(
      id: '3',
      category: ReviewCategory.parking,
      question:
          '¿El establecimiento cuenta con estacionamiento exclusivo y accesible para personas que lo requieran?',
    ),
    ReviewQuestion(
      id: '4',
      category: ReviewCategory.restrooms,
      question: '¿Existe un bano inclusivo habilitado?',
    ),
    ReviewQuestion(
      id: '5',
      category: ReviewCategory.restrooms,
      question: '¿El bano inclusivo esta en buenas condiciones?',
    ),
    ReviewQuestion(
      id: '6',
      category: ReviewCategory.circulation,
      question:
          '¿Se puede circular con facilidad y accesibilidad dentro del establecimiento?',
    ),
  ];

  void _onNextRequested(ReviewNextRequested event, Emitter<ReviewState> emit) {
    if (state.currentQuestionIndex < state.questions.length - 1) {
      final nextIndex = state.currentQuestionIndex + 1;
      emit(
        state.copyWith(
          currentQuestionIndex: nextIndex,
          selectedCategory: state.questions[nextIndex].category,
        ),
      );
    }
  }

  void _onRateChoiceChanged(
    ReviewRateChoiceChanged event,
    Emitter<ReviewState> emit,
  ) {
    emit(
      state.copyWith(
        rateChoice: event.rateChoice,
        submissionStatus: ReviewSubmissionStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onSubmitRequested(
    ReviewSubmitRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(
      state.copyWith(
        submissionStatus: ReviewSubmissionStatus.loading,
        clearErrorMessage: true,
      ),
    );

    developer.log(
      'Submitting review | placeId=${event.placeId} | rateChoice=${event.rateChoice} | forms=${event.forms}',
      name: 'ReviewBloc',
    );

    final result = await savePlaceStatDataUseCase(
      SavePlaceStatDataParams(
        placeId: event.placeId,
        rateChoice: event.rateChoice,
        forms: event.forms,
      ),
    );

    result.fold(
      (failure) {
        developer.log(
          'Review submit failed | status=${failure.statusCode} | message=${failure.message}',
          name: 'ReviewBloc',
        );
        emit(
          state.copyWith(
            submissionStatus: ReviewSubmissionStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        developer.log('Review submit success', name: 'ReviewBloc');
        emit(
          state.copyWith(
            submissionStatus: ReviewSubmissionStatus.success,
            step: ReviewStep.success,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  void _onCategorySelected(
    ReviewCategorySelected event,
    Emitter<ReviewState> emit,
  ) {
    final questions = state.questions;

    // Buscar la primera pregunta que pertenece a la categoría seleccionada
    final initialIndex = questions.indexWhere(
      (q) => q.category == event.category,
    );

    emit(
      state.copyWith(
        step: ReviewStep.form,
        selectedCategory: event.category,
        questions: questions,
        currentQuestionIndex: initialIndex != -1 ? initialIndex : 0,
        submissionStatus: ReviewSubmissionStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  void _onQuestionAnswered(
    ReviewQuestionAnswered event,
    Emitter<ReviewState> emit,
  ) {
    final updatedQuestions = List<ReviewQuestion>.from(state.questions);
    final index = updatedQuestions.indexWhere((q) => q.id == event.questionId);

    if (index != -1) {
      updatedQuestions[index] = updatedQuestions[index].copyWith(
        answer: event.answer,
      );

      // Actualizar la categoría seleccionada basándose en la nueva posición
      final nextIndex = index + 1;
      final nextCategory = nextIndex < updatedQuestions.length
          ? updatedQuestions[nextIndex].category
          : state.selectedCategory;

      if (index < updatedQuestions.length - 1) {
        emit(
          state.copyWith(
            questions: updatedQuestions,
            currentQuestionIndex: nextIndex,
            selectedCategory: nextCategory,
            submissionStatus: ReviewSubmissionStatus.initial,
            clearErrorMessage: true,
          ),
        );
      } else {
        // Ultima pregunta respondida: volver al menu para enviar formulario.
        emit(
          state.copyWith(
            questions: updatedQuestions,
            currentQuestionIndex: index,
            step: ReviewStep.menu,
            selectedCategory: null,
            submissionStatus: ReviewSubmissionStatus.initial,
            clearErrorMessage: true,
          ),
        );
      }
    }
  }

  void _onBackRequested(ReviewBackRequested event, Emitter<ReviewState> emit) {
    if (state.step == ReviewStep.form) {
      if (state.currentQuestionIndex > 0) {
        final prevIndex = state.currentQuestionIndex - 1;
        emit(
          state.copyWith(
            currentQuestionIndex: prevIndex,
            selectedCategory: state.questions[prevIndex].category,
          ),
        );
      } else {
        emit(ReviewState(questions: state.questions));
      }
    } else if (state.step == ReviewStep.success) {
      emit(
        state.copyWith(
          step: ReviewStep.form,
          currentQuestionIndex: state.questions.length - 1,
          selectedCategory: state.questions.last.category,
          submissionStatus: ReviewSubmissionStatus.initial,
          clearErrorMessage: true,
        ),
      );
    }
  }

  void _onReset(ReviewReset event, Emitter<ReviewState> emit) {
    emit(ReviewState(questions: state.questions));
  }
}
