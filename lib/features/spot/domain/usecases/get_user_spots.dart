import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para obtener los spots de un usuario.
class GetUserSpots {
  final SpotRepository repository;

  GetUserSpots(this.repository);

  Future<List<Spot>> call(String userId) async {
    return await repository.getUserSpots(userId);
  }
}
