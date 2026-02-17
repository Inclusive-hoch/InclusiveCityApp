import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para eliminar un spot de una lista personalizada.
class DeleteSpotFromList {
  final SpotRepository repository;

  DeleteSpotFromList(this.repository);

  Future<int> call(
    String listName,
    double latitude,
    double longitude,
  ) async {
    return await repository.deleteSpotFromList(
      listName,
      latitude,
      longitude,
    );
  }
}
