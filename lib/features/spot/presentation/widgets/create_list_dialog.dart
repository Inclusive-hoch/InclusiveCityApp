import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';

/// Diálogo para crear una nueva lista personalizada.
/// 
/// Solicita al usuario un nombre para la lista y valida que no esté vacío.
class CreateListDialog extends StatefulWidget {
  /// Callback ejecutado cuando se confirma la creación con un nombre válido.
  final void Function(String listName) onConfirm;

  const CreateListDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<CreateListDialog> createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      final listName = _controller.text.trim();
      Navigator.of(context).pop();
      widget.onConfirm(listName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear nueva lista'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: 'Nombre de la lista',
            hintText: 'Ej: Mis restaurantes favoritos',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre no puede estar vacío';
            }
            if (value.trim().length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleConfirm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primaryNormal,
            foregroundColor: Colors.white,
          ),
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
