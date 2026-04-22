import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/utils/speech_helper.dart';
import 'package:inclusive_app/features/places/presentation/bloc/place_bloc.dart';

/// Widget de búsqueda de lugares con reconocimiento de voz.
/// Permite búsqueda por texto y por voz usando speech-to-text.
class SearchBar extends StatefulWidget {
  const SearchBar({super.key});
  
  @override
  State<StatefulWidget> createState() => _SearchBar();
}

/// Estado del widget SearchBar.
/// Maneja el controlador del texto, reconocimiento de voz y eventos del BLoC.
class _SearchBar extends State<SearchBar> {
  /// Controlador del campo de texto de búsqueda.
  late final TextEditingController _searchController;
  
  /// Nodo de foco para el campo de texto.
  final _focusNode = FocusNode();
  
  /// Helper para el reconocimiento de voz.
  final _speechHelper = SpeechHelper();

  /// Inicializa el controlador de texto y el servicio de reconocimiento de voz.
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initializeSpeech();
  }

  /// Libera los recursos del controlador y el nodo de foco.
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Inicializa el servicio de reconocimiento de voz.
  /// Configura callbacks para errores y cambios de estado.
  Future<void> _initializeSpeech() async {
    await _speechHelper.initialize(
      onError: (error) => log('Error speech: $error'),
      onStatus: (status) {
        log('Status speech: $status');
        setState(() {}); // Actualizar UI cuando cambia el estado
      },
    );
  }

  /// Construye el widget de búsqueda.
  /// Incluye campo de texto con icono de búsqueda y botón de micrófono.
  /// Emite eventos al BLoC según el texto ingresado.
  @override
  Widget build(BuildContext context) {
    // Bug 6: limpia el TextField cuando el usuario navega al detalle de un lugar
    return BlocListener<PlaceBloc, PlacesState>(
      listener: (context, state) {
        if (state is PlaceDetailsLoaded) {
          _searchController.clear();
          context.read<PlaceBloc>().add(LoadSearchHistoryEvent());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: "¿Adónde vas?",
            hintStyle: const TextStyle(color: AppColor.neutralDarkNormal),
            filled: true,
            fillColor: AppColor.neutralLight,
            prefixIcon: const Icon(Icons.search, color: AppColor.primaryNormal),
            suffixIcon: IconButton(
              icon: Icon(
                _speechHelper.isListening ? Icons.mic : Icons.mic_none,
                color: _speechHelper.isListening ? AppColor.error : AppColor.primaryNormal,
              ),
              onPressed: () {
                if (!_speechHelper.isAvailable) {
                  log('Reconocimiento de voz no disponible');
                  return;
                }

                if (_speechHelper.isListening) {
                  _speechHelper.stop();
                } else {
                  _speechHelper.listen(
                    onResult: (text) {
                      _searchController.text = text;
                      // Bug 4: también disparar la búsqueda al reconocer voz
                      if (text.isNotEmpty) {
                        context.read<PlaceBloc>().add(SearchPlacesEvent(text));
                      }
                    },
                  );
                }
                setState(() {});
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onChanged: (query) {
            if (query.isEmpty) {
              context.read<PlaceBloc>().add(LoadSearchHistoryEvent());
            } else {
              context.read<PlaceBloc>().add(SearchPlacesEvent(query));
            }
          },
        ),
      ),
    );
  }
}
