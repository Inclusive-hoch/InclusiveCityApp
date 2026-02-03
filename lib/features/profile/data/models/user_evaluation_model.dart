import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

/// Modelo de datos para UserEvaluation que maneja la serialización JSON
class UserEvaluationModel extends UserEvaluation {
  const UserEvaluationModel({
    required super.placeId,
    required super.rate,
    required super.forms,
  });

  //Crea la instancia desde un json
  factory UserEvaluationModel.fromJson(Map<String, dynamic> json) {
    return UserEvaluationModel(
      placeId: json['placeid'] as String,
      rate: json['rate'] as String,
      forms: List<String>.from(json['forms'] ?? []),
    );
  }

  //mapea a json
  Map<String, dynamic> toJson(){
    return {
      'placeid': placeId,
      'rate': rate,
      'forms': forms,
    };
  }
}
