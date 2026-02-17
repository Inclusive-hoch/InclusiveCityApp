import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para eliminar un spot por coordenadas.
class DeleteSpot {
  final SpotRepository repository;

  DeleteSpot(this.repository);

  Future<void> call(double latitude, double longitude) async {
    return await repository.deleteSpot(latitude, longitude);
  }
}
