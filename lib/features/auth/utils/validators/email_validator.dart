String? validateEmail(value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa tu email';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Por favor ingresa un email válido';
  }
  return null;
}
