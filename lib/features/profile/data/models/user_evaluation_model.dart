import 'package:inclusive_app/features/profile/domain/entities/user_evaluation.dart';

/// Modelo de datos para UserEvaluation que maneja la serialización JSON
class UserEvaluationModel extends UserEvaluation {
  const UserEvaluationModel({
    required super.placeId,
    required super.medals,
    required super.rating,
    required super.rateChoice,
    required super.forms,
  });

  /// Crea la instancia desde un json con el nuevo formato
  /// El formato esperado es:
  /// {
  ///   "placeId": "123",
  ///   "medals": ["ATENCION_PREFERENCIAL", ...],
  ///   "rating": 100.0,
  ///   "statsData": {
  ///     "userId": {
  ///       "rateChoice": "LIKE",
  ///       "forms": ["YES", "YES", ...]
  ///     }
  ///   }
  /// }
  factory UserEvaluationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final statsData = json['statsData'] as Map<String, dynamic>? ?? {};

    // Obtener los datos del usuario actual desde statsData
    final userStats = statsData[currentUserId] as Map<String, dynamic>?;

    // Si no hay statsData (formato de caché), leer directamente del JSON
    final rateChoice = userStats?['rateChoice'] as String? ?? 
                      json['rateChoice'] as String? ?? 
                      'UNKNOWN';
    
    final forms = userStats?['forms'] != null 
        ? List<String>.from(userStats!['forms'])
        : List<String>.from(json['forms'] ?? []);

    return UserEvaluationModel(
      placeId: json['placeId'] as String,
      medals: List<String>.from(json['medals'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      rateChoice: rateChoice,
      forms: forms,
    );
  }

  /// Mapea a json
  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'medals': medals,
      'rating': rating,
      'rateChoice': rateChoice,
      'forms': forms,
    };
  }
}
