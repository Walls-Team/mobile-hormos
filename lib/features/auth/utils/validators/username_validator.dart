String? validateUsername(value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa un nombre de usuario';
  }
  if (value.length < 2) {
    return 'El usuario debe tener al menos 2 caracteres';
  }
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
    return 'Solo se permiten letras, números y guiones bajos';
  }
  return null;
}
