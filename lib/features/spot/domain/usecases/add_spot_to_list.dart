import 'package:inclusive_app/features/spot/domain/entities/custom_spot.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/features/spot/domain/repositories/spot_repository.dart';

/// Caso de uso para agregar un spot a una lista personalizada.
class AddSpotToList {
  final SpotRepository repository;

  AddSpotToList(this.repository);

  Future<CustomSpot> call(String listName, Spot spot) async {
    return await repository.addSpotToList(listName, spot);
  }
}
