enum ReviewCategory {
  preferentialAttention(
    'Atención preferencial',
    'assets/accesibilityForm/handshake.svg',
  ),
  accessibility('Accesibilidad', 'assets/accesibilityForm/accessible.svg'),
  restrooms('Baños', 'assets/accesibilityForm/bath.svg'),
  parking('Estacionamiento', 'assets/accesibilityForm/estacionamiento.svg'),
  circulation('Circulación', 'assets/accesibilityForm/circulación.svg');

  final String label;
  final String iconPath;

  const ReviewCategory(this.label, this.iconPath);
}
