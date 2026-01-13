import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Helper para gestionar el reconocimiento de voz en español.
/// Simplifica el uso de speech_to_text en la aplicación.
class SpeechHelper {
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Indica si el reconocimiento de voz está actualmente escuchando.
  bool get isListening => _speech.isListening;

  /// Indica si el servicio de reconocimiento está disponible.
  bool get isAvailable => _speech.isAvailable;

  /// Inicializa el servicio de reconocimiento de voz.
  /// Retorna true si la inicialización fue exitosa.
  Future<bool> initialize({
    required Function(String) onError,
    required Function(String) onStatus,
  }) async {
    return await _speech.initialize(
      onError: (val) => onError(val.errorMsg),
      onStatus: onStatus,
    );
  }

  /// Inicia la escucha de voz en español.
  /// Los resultados reconocidos se envían a través del callback [onResult].
  void listen({required Function(String) onResult}) {
    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: 'es_ES',
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Detiene la escucha de voz.
  void stop() => _speech.stop();

  /// Cancela la escucha de voz sin procesar resultados pendientes.
  void cancel() => _speech.cancel();
}