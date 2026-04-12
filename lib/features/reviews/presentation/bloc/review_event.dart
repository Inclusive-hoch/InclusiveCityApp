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

class ReviewRateChoiceChanged extends ReviewEvent {
  final String rateChoice;

  const ReviewRateChoiceChanged(this.rateChoice);

  @override
  List<Object?> get props => [rateChoice];
}

class ReviewSubmitRequested extends ReviewEvent {
  final String placeId;
  final List<String> forms;

  const ReviewSubmitRequested({
    required this.placeId,
    required this.forms,
  });

  @override
  List<Object?> get props => [placeId, forms];
}

class ReviewNextRequested extends ReviewEvent {}

class ReviewReset extends ReviewEvent {}
