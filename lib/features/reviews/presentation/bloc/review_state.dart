import 'package:equatable/equatable.dart';
import '../../domain/entities/review_category.dart';
import '../../domain/entities/review_question.dart';

enum ReviewStep { menu, form, success }

class ReviewState extends Equatable {
  final ReviewStep step;
  final ReviewCategory? selectedCategory;
  final List<ReviewQuestion> questions;
  final int currentQuestionIndex;

  const ReviewState({
    this.step = ReviewStep.menu,
    this.selectedCategory,
    this.questions = const [],
    this.currentQuestionIndex = 0,
  });

  ReviewState copyWith({
    ReviewStep? step,
    ReviewCategory? selectedCategory,
    List<ReviewQuestion>? questions,
    int? currentQuestionIndex,
  }) {
    return ReviewState(
      step: step ?? this.step,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }

  @override
  List<Object?> get props => [
    step,
    selectedCategory,
    questions,
    currentQuestionIndex,
  ];

  double get progress =>
      questions.isEmpty ? 0.0 : (currentQuestionIndex + 1) / questions.length;
}
