import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';

class AppConstants {
  static const List<String> genders = [
    'Masculino',
    'Femenino',
    'Otro',
    'Prefiero no decir',
  ];
}

class InputDecorations {
  static InputDecoration textFormFieldDecoration(
    String label,
    BuildContext context,
  ) {
    return InputDecoration(
      hintText: label,
      // hintStyle: const TextStyle(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: neutral_600,

      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
    );
  }

  static InputDecoration dropdownDecoration(BuildContext context) {
    return InputDecoration(
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: neutral_600,
      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
    );
  }

  static InputDecoration heightDecoration(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return InputDecoration(
      hintText: localizations != null ? localizations['inputPlaceholders']['heightPlaceholder'] : "5'9\"",
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: neutral_600,
      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
    );
  }

  static InputDecoration weightDecoration(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return InputDecoration(
      hintText: localizations != null ? localizations['inputPlaceholders']['weightPlaceholder'] : "134",
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: neutral_600,
      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
    );
  }

  static InputDecoration birthDateDecoration(BuildContext context) {
    return InputDecoration(
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: neutral_600,
      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
    );
  }

  static InputDecoration disabledFieldDecoration(
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return InputDecoration(
      // labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      // prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: neutral_600,

      border: InputBorder.none, // Quitamos el borde
      enabledBorder: InputBorder.none, // Quitamos el borde cuando está enabled
      focusedBorder: InputBorder.none, // Quitamos el borde cuando está focused
      errorBorder: InputBorder.none, // Quitamos el borde cuando hay error
      focusedErrorBorder:
          InputBorder.none, // Quitamos el borde cuando hay error y está focused
      disabledBorder: InputBorder.none,
      // fillColor: Colors.grey[800],
    );
  }
}

class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu altura';
    }
    final height = double.tryParse(value);
    if (height == null || height <= 0) {
      return 'Por favor ingresa una altura válida';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu peso';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight <= 0) {
      return 'Por favor ingresa un peso válido';
    }
    return null;
  }
}

class AppButtonStyles {
  static final primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary600,
    foregroundColor: Colors.black,
    textStyle: TextStyle(color: Colors.black),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: black,
    foregroundColor: Colors.white,
    textStyle: TextStyle(color: Colors.black),
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final disabledButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[600],
    foregroundColor: Colors.grey[400],
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final infoButton = ElevatedButton.styleFrom(
    backgroundColor: info_600,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}
