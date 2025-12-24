import 'package:flutter/material.dart';

class SaveSpotDialog extends StatefulWidget {
  final String placeId;
  final String address;
  final double latitude;
  final double longitude;

  const SaveSpotDialog({
    super.key,
    required this.placeId,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<SaveSpotDialog> createState() => _SaveSpotDialogState();
}

class _SaveSpotDialogState extends State<SaveSpotDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedType = 'Casa';

  final List<Map<String, dynamic>> _spotTypes = [
    {'value': 'Casa', 'icon': Icons.home, 'label': 'Casa', 'requiresName': false},
    {'value': 'Trabajo', 'icon': Icons.work, 'label': 'Trabajo', 'requiresName': false},
    {'value': 'Otro', 'icon': Icons.location_on, 'label': 'Otro', 'requiresName': true},
  ];

  bool _requiresCustomName() {
    final type = _spotTypes.firstWhere((t) => t['value'] == _selectedType);
    return type['requiresName'] as bool;
  }

  String _getSpotName() {
    if (_requiresCustomName()) {
      return _nameController.text.trim();
    }
    return _selectedType; // Usa el tipo como nombre para Casa, Trabajo, etc.
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.bookmark_add,
                    color: Color(0xFF4A90E2),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Guardar Lugar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Address display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Type selector (primero para que se seleccione antes del nombre)
              const Text(
                'Tipo de lugar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _spotTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(type['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type['value'] as String;
                        // Limpiar el campo de nombre si cambia a un tipo que no requiere nombre
                        if (!_requiresCustomName()) {
                          _nameController.clear();
                        }
                      });
                    },
                    selectedColor: const Color(0xFF4A90E2),
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Name input (solo visible si se selecciona "Otro")
              if (_requiresCustomName())
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del lugar',
                        hintText: 'Ej: Parque Favorito, Restaurante, etc.',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (_requiresCustomName() && (value == null || value.trim().isEmpty)) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).pop({
                          'name': _getSpotName(),
                          'type': _selectedType,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
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
      ),
    );
  }
}
