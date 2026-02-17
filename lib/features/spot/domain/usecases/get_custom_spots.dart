import 'package:inclusive_app/features/spot/data/models/custom_spot_model.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para obtener todas las listas personalizadas de spots.
class GetCustomSpots {
  final SpotRepository repository;

  GetCustomSpots(this.repository);

  Future<List<CustomSpotModel>> call() async {
    return await repository.getCustomSpots();
  }
}
