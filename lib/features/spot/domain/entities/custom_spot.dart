import 'package:equatable/equatable.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';

/// Entidad de dominio que representa una lista personalizada de spots.
/// 
/// Permite a los usuarios organizar sus spots en colecciones temáticas
/// como "Restaurantes favoritos", "Lugares accesibles", etc.
class CustomSpot extends Equatable {
  /// ID único de la lista (puede ser null si no ha sido guardada).
  final String? id;
  
  /// ID del usuario propietario de la lista.
  final String userId;
  
  /// Nombre de la lista personalizada.
  final String listName;
  
  /// Lista de spots incluidos en esta colección.
  final List<Spot> spotList;

  const CustomSpot({
    required this.id,
    required this.userId,
    required this.listName,
    required this.spotList,
  });

  @override
  List<Object?> get props => [id, userId, listName, spotList];
}
