import 'package:inclusive_app/features/spot/data/models/custom_spot_model.dart';
import 'package:inclusive_app/features/spot/data/models/spot_model.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para agregar un spot a una lista personalizada.
class AddSpotToList {
  final SpotRepository repository;

  AddSpotToList(this.repository);

  Future<CustomSpotModel> call(String listName, SpotModel spot) async {
    return await repository.addSpotToList(listName, spot);
  }
}
