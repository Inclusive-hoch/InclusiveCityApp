import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/review_category.dart';
import '../../domain/entities/review_question.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(const ReviewState()) {
    on<ReviewCategorySelected>(_onCategorySelected);
    on<ReviewQuestionAnswered>(_onQuestionAnswered);
    on<ReviewBackRequested>(_onBackRequested);
    on<ReviewFinalizeRequested>(_onFinalizeRequested);
    on<ReviewNextRequested>(_onNextRequested);
    on<ReviewReset>(_onReset);
  }

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

  void _onFinalizeRequested(
    ReviewFinalizeRequested event,
    Emitter<ReviewState> emit,
  ) {
    emit(state.copyWith(step: ReviewStep.success));
  }

  void _onCategorySelected(
    ReviewCategorySelected event,
    Emitter<ReviewState> emit,
  ) {
    final questions = _getGlobalQuestions();

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
          ),
        );
      } else {
        // Última pregunta respondida
        emit(
          state.copyWith(questions: updatedQuestions, step: ReviewStep.success),
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
        emit(const ReviewState());
      }
    } else if (state.step == ReviewStep.success) {
      emit(
        state.copyWith(
          step: ReviewStep.form,
          currentQuestionIndex: state.questions.length - 1,
          selectedCategory: state.questions.last.category,
        ),
      );
    }
  }

  void _onReset(ReviewReset event, Emitter<ReviewState> emit) {
    emit(const ReviewState());
  }

  List<ReviewQuestion> _getGlobalQuestions() {
    return const [
      ReviewQuestion(
        id: '1',
        category: ReviewCategory.preferentialAttention,
        question:
            '¿Existe atención preferencial para personas que lo requieran?',
      ),
      ReviewQuestion(
        id: '2',
        category: ReviewCategory.accessibility,
        question:
            '¿El acceso al establecimiento es fácil para todas las personas?',
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
        question: '¿Existe un baño inclusivo habilitado?',
      ),
      ReviewQuestion(
        id: '5',
        category: ReviewCategory.restrooms,
        question: '¿El baño inclusivo esta en buenas condiciones?',
      ),
      ReviewQuestion(
        id: '6',
        category: ReviewCategory.circulation,
        question:
            '¿Se puede circular con facilidad dentro del establecimiento?',
      ),
    ];
  }
}
