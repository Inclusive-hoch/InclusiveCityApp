import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:inclusive_app/core/theme/app_color.dart';
import 'package:inclusive_app/core/widgets/custom_filled_button.dart';

/// Página completa de cámara para capturar foto de incidencia.
///
/// Retorna el path de la foto (`String`) si el usuario acepta,
/// o `null` si cancela.
class IncidentCameraPage extends StatefulWidget {
  const IncidentCameraPage({super.key});

  @override
  State<IncidentCameraPage> createState() => _IncidentCameraPageState();
}

class _IncidentCameraPageState extends State<IncidentCameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _capturedPhotoPath;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró ninguna cámara')),
        );
        Navigator.of(context).pop(null);
      }
      return;
    }

    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final photo = await _controller!.takePicture();
    setState(() => _capturedPhotoPath = photo.path);
  }

  void _retryPhoto() {
    setState(() => _capturedPhotoPath = null);
  }

  void _acceptPhoto() {
    Navigator.of(context).pop(_capturedPhotoPath);
  }

  void _cancel() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _capturedPhotoPath != null
            ? _buildPreview()
            : _buildCameraLive(),
      ),
    );
  }

  /// Vista en vivo de la cámara con botón de captura.
  Widget _buildCameraLive() {
    return Column(
      children: [
        Expanded(
          child: _isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CameraPreview(_controller!),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColor.neutralLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomFilledButton(
                  label: 'Cancelar',
                  style: CustomButtonStyle.secondary,
                  onPressed: _cancel,
                ),
              ),
              const SizedBox(width: 16),
              // Botón circular de captura
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primaryNormalActive,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Espacio simétrico para centrar el botón de captura
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  /// Preview de la foto capturada con opciones Reintentar / Aceptar.
  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_capturedPhotoPath!),
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColor.neutralLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomFilledButton(
                      label: 'Reintentar',
                      style: CustomButtonStyle.secondary,
                      onPressed: _retryPhoto,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomFilledButton(
                      label: 'Aceptar',
                      style: CustomButtonStyle.primary,
                      onPressed: _acceptPhoto,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _cancel,
                child: Text(
                  'Cancelar registro',
                  style: TextStyle(
                    color: AppColor.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
