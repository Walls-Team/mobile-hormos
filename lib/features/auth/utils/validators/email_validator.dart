String? validateEmail(value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  // More permissive regular expression that allows:
  // - Alphanumeric characters
  // - Dots (.)
  // - Hyphens (-)
  // - Underscores (_)
  // - Plus signs (+) - used in Gmail for testing
  if (!RegExp(r'^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}
