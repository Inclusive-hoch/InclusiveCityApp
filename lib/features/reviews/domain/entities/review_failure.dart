import 'package:equatable/equatable.dart';

class ReviewFailure extends Equatable {
  final String message;
  final int? statusCode;

  const ReviewFailure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
