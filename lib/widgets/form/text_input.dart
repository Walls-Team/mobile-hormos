import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';

class InputText extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool expands;

  const InputText({
    super.key,
    required this.controller,
    this.hintText = 'Ingresa el texto',
    this.validator,
    this.contentPadding,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
  });

  @override
  State<InputText> createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      decoration: InputDecoration(
        hintText: widget.hintText,
        contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: neutral_600,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }
}