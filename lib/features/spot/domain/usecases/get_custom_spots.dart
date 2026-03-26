import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para obtener todas las listas personalizadas de spots.
class GetCustomSpots {
  final SpotRepository repository;

  GetCustomSpots(this.repository);

  Future<List<CustomSpot>> call() async {
    return await repository.getCustomSpots();
  }
}
