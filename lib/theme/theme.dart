import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';

ThemeData theme = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Color(0xFF1C1D23), //color de fondo
    onSurface: Color(0xFF9D9D9D), //color del texto sobre fondo
    // surfaceContainerHighest: Color(0xFFF8F9FA), // Containers secundarios
    // onSurfaceVariant: Color(0xFF6C7079), // Texto sobre surfaceVariant
    //OUTLINE (Bordes)
    outline: primary600,           // Bordes normales de inputs
    outlineVariant: primary500,    // Bordes muy sutiles

    primary: primary600,
    onPrimary: Colors.black,
  ),

  textTheme: TextTheme(
    bodyLarge: TextStyle(color: const Color(0xFFBBBBBB)),
    bodyMedium: TextStyle(color: const Color(0xFFBBBBBB)),
    bodySmall: TextStyle(color: const Color(0xFFBBBBBB)),

    headlineLarge: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
    headlineSmall: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary600, // Color de fondo
      foregroundColor: Colors.black, // Color del texto/icono
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: Size(double.infinity, 50),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white, // Color del texto/icono
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: Size(double.infinity, 50),
      side: BorderSide(color: Colors.white),
    ),
  ),

  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Color(0xFF2A2C3B),
  ),

inputDecorationTheme: InputDecorationTheme(
    // BORDES
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      // borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),

    // FONDO Y RELLENO
    filled: true,
    fillColor: const Color(0xFF2A2C3B),

    suffixIconColor: const Color(0xFF9D9D9D),

    // TEXTO Y ESTILOS
    labelStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ),
    hintStyle: TextStyle(
      color: const Color(0xFF9D9D9D),
      fontSize: 16,
    ),
    errorStyle: TextStyle(
      color: Colors.red,
      fontSize: 14,
    ),

    // ESPACIADO Y TAMAÑO
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    
    // PREFIJO/SUFIJO
    prefixStyle: TextStyle(color: Color(0xFF1C1D23)),
    suffixStyle: TextStyle(color: Color(0xFF1C1D23)),
  ),

);
