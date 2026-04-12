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
    final userStats = _extractUserStats(json['statsData'], currentUserId);

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

  /// Soporta ambos formatos de backend:
  /// - Map con userId como llave
  /// - Lista de objetos con userId/rateChoice/forms
  static Map<String, dynamic>? _extractUserStats(
    dynamic rawStatsData,
    String currentUserId,
  ) {
    if (rawStatsData is Map<String, dynamic>) {
      final value = rawStatsData[currentUserId];
      if (value is Map<String, dynamic>) {
        return value;
      }
      return null;
    }

    if (rawStatsData is List) {
      for (final item in rawStatsData) {
        if (item is Map<String, dynamic> && item['userId'] == currentUserId) {
          return item;
        }
      }
    }

    return null;
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
