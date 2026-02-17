import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para eliminar una lista personalizada completa.
class DeleteCustomSpotList {
  final SpotRepository repository;

  DeleteCustomSpotList(this.repository);

  Future<int> call(String listName) async {
    return await repository.deleteCustomSpotList(listName);
  }
}
