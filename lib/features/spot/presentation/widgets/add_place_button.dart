import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Botón para agregar un nuevo lugar guardado.
class AddPlaceButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AddPlaceButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColor.primaryLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: AppColor.primaryNormal,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Agregar un lugar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
