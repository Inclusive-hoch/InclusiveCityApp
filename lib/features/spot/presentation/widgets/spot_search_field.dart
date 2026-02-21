import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Campo de búsqueda reutilizable para spots.
/// 
/// Widget independiente que encapsula la UI del campo de búsqueda
/// con sus decoraciones y comportamiento.
class SpotSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  const SpotSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Buscar dirección',
          hintStyle: const TextStyle(
            color: AppColor.neutralDarkNormal,
          ),
          filled: true,
          fillColor: AppColor.neutralLight,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColor.secondaryNormal,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColor.secondaryNormal,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
