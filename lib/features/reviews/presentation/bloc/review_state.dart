import 'package:equatable/equatable.dart';
import '../../domain/entities/review_category.dart';
import '../../domain/entities/review_question.dart';

enum ReviewStep { menu, form, success }

enum ReviewSubmissionStatus { initial, loading, success, failure }

class ReviewState extends Equatable {
  final ReviewStep step;
  final ReviewCategory? selectedCategory;
  final List<ReviewQuestion> questions;
  final int currentQuestionIndex;
  final String rateChoice;
  final ReviewSubmissionStatus submissionStatus;
  final String? errorMessage;

  const ReviewState({
    this.step = ReviewStep.menu,
    this.selectedCategory,
    this.questions = const [],
    this.currentQuestionIndex = 0,
    this.rateChoice = 'DISLIKE',
    this.submissionStatus = ReviewSubmissionStatus.initial,
    this.errorMessage,
  });

  ReviewState copyWith({
    ReviewStep? step,
    ReviewCategory? selectedCategory,
    List<ReviewQuestion>? questions,
    int? currentQuestionIndex,
    String? rateChoice,
    ReviewSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ReviewState(
      step: step ?? this.step,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      rateChoice: rateChoice ?? this.rateChoice,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    step,
    selectedCategory,
    questions,
    currentQuestionIndex,
    rateChoice,
    submissionStatus,
    errorMessage,
  ];

  double get progress =>
      questions.isEmpty ? 0.0 : (currentQuestionIndex + 1) / questions.length;

  bool get isSubmitting => submissionStatus == ReviewSubmissionStatus.loading;
}
