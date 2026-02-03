import 'package:equatable/equatable.dart';

class UserEvaluation extends Equatable {
  final String placeId;
  final String rate;
  final List<String> forms;

  const UserEvaluation({
    required this.placeId,
    required this.rate,
    required this.forms,
  });

  @override
  List<Object?> get props => [placeId, rate, forms];
}