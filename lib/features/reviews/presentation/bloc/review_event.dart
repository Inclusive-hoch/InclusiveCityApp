import 'package:equatable/equatable.dart';
import '../../domain/entities/review_category.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class ReviewCategorySelected extends ReviewEvent {
  final ReviewCategory category;

  const ReviewCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

class ReviewQuestionAnswered extends ReviewEvent {
  final String questionId;
  final bool answer;

  const ReviewQuestionAnswered(this.questionId, this.answer);

  @override
  List<Object?> get props => [questionId, answer];
}

class ReviewBackRequested extends ReviewEvent {}

class ReviewFinalizeRequested extends ReviewEvent {}

class ReviewNextRequested extends ReviewEvent {}

class ReviewReset extends ReviewEvent {}
