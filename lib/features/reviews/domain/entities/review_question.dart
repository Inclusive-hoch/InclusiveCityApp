import 'review_category.dart';

class ReviewQuestion {
  final String id;
  final String question;
  final ReviewCategory category;
  final bool? answer; // true = Yes, false = No, null = Not answered

  const ReviewQuestion({
    required this.id,
    required this.question,
    required this.category,
    this.answer,
  });

  ReviewQuestion copyWith({bool? answer}) {
    return ReviewQuestion(
      id: id,
      question: question,
      category: category,
      answer: answer,
    );
  }
}
