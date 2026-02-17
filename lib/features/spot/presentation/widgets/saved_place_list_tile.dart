import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/features/spot/domain/entities/spot.dart';
import 'package:inclusive_app/shared/extensions/spot_type_extension.dart';

/// Widget para mostrar un lugar guardado en la lista.
/// 
/// Incluye:
/// - Icono según el tipo de lugar
/// - Nombre del lugar
/// - Dirección (opcional)
/// - Acción de deslizar para eliminar
class SavedPlaceListTile extends StatelessWidget {
  /// El spot a mostrar.
  final Spot spot;

  /// Callback cuando se toca el tile.
  final VoidCallback? onTap;

  /// Callback cuando se elimina el spot.
  final VoidCallback? onDelete;

  /// Si debe mostrar la dirección como subtítulo.
  final bool showAddress;

  const SavedPlaceListTile({
    super.key,
    required this.spot,
    this.onTap,
    this.onDelete,
    this.showAddress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${spot.latitude}-${spot.longitude}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColor.accentNormal,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Eliminar lugar'),
              content: Text(
                '¿Estás seguro de que deseas eliminar "${spot.spotName}"?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.accentNormal,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            spot.type.spotIcon,
            color: AppColor.primaryNormal,
            size: 24,
          ),
        ),
        title: Text(
          spot.spotName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.secondaryDarker,
          ),
        ),
        subtitle: showAddress && spot.address.isNotEmpty
            ? Text(
                spot.address,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColor.secondaryNormal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColor.secondaryNormal,
        ),
        onTap: onTap,
      ),
    );
  }
}
