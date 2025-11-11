String? validateEmail(value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu email';
  }
  // Expresión regular más permisiva que permite:
  // - Caracteres alfanuméricos
  // - Puntos (.)
  // - Guiones (-)
  // - Guiones bajos (_)
  // - Signos más (+) - usado en Gmail para testing
  if (!RegExp(r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
    return 'Por favor ingresa un email válido';
  }
  return null;
}
