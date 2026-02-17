import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Modal para ingresar el nombre de un lugar antes de guardarlo.
/// 
/// Muestra un diálogo con:
/// - Título "Ponele un nombre"
/// - Campo de texto para el nombre
/// - Botones "Cancelar" y "Listo"
class PlaceNameDialog extends StatefulWidget {
  /// Nombre sugerido inicial (del lugar seleccionado).
  final String? initialName;

  /// Callback al confirmar con el nombre ingresado.
  final Function(String name) onConfirm;

  /// Callback al cancelar.
  final VoidCallback? onCancel;

  const PlaceNameDialog({
    super.key,
    this.initialName,
    required this.onConfirm,
    this.onCancel,
  });

  @override
  State<PlaceNameDialog> createState() => _PlaceNameDialogState();
}

class _PlaceNameDialogState extends State<PlaceNameDialog> {
  late TextEditingController _nameController;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _isValid = _nameController.text.trim().isNotEmpty;
    _nameController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Valida que el campo no esté vacío.
  void _validateInput() {
    setState(() {
      _isValid = _nameController.text.trim().isNotEmpty;
    });
  }

  /// Maneja la confirmación del nombre.
  void _handleConfirm() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onConfirm(name);
      Navigator.of(context).pop();
    }
  }

  /// Maneja la cancelación.
  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ponele un nombre',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColor.secondaryDarker,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Lugar',
                hintStyle: const TextStyle(
                  color: AppColor.neutralDarkNormal,
                ),
                filled: true,
                fillColor: AppColor.neutralLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColor.neutralDarkNormal,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColor.neutralDarkNormal,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColor.primaryNormal,
                    width: 2,
                  ),
                ),
                counterText: '',
              ),
              onSubmitted: (_) {
                if (_isValid) {
                  _handleConfirm();
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _handleCancel,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColor.secondaryNormal,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isValid ? _handleConfirm : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryNormal,
                    disabledBackgroundColor: AppColor.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Listo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
