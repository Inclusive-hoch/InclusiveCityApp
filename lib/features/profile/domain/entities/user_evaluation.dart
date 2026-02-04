import 'package:equatable/equatable.dart';

class UserEvaluation extends Equatable {
  final String placeId;
  final List<String> medals;
  final double rating;
  final String rateChoice; // LIKE o DISLIKE
  final List<String> forms;

  const UserEvaluation({
    required this.placeId,
    required this.medals,
    required this.rating,
    required this.rateChoice,
    required this.forms,
  });

  @override
  List<Object?> get props => [placeId, medals, rating, rateChoice, forms];
}
