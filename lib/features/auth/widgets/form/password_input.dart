import 'package:flutter/material.dart';

class InputPassword extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(void)? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  const InputPassword({
    super.key,
    required this.controller,
    this.hintText = '********',
    this.validator,
    this.contentPadding,
    this.onChanged,
  });

  @override
  State<InputPassword> createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
      onChanged: widget.onChanged ?? _defaultOnChanged,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < 6) {
      return 'Minimum 6 characters';
    }
    return null;
  }

  void _defaultOnChanged(String? value) {
    return;
  }
}
