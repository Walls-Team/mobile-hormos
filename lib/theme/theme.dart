import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/colors_pallete.dart';

ThemeData theme = ThemeData(
  colorScheme: ColorScheme.light(
    surface: black,
    onSurface: white,
    primary: primary600,
    error: danger_600,
    outline: primary500,
  ),

  extensions: <ThemeExtension<dynamic>>[
    AppGradientTheme(
      backgroundGradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      primaryGradient: LinearGradient(colors: [Colors.red, Colors.orange]),
      secondaryGradient: LinearGradient(colors: [Colors.green, Colors.teal]),
    ),
  ],

  textTheme: TextTheme(
    bodyLarge: TextStyle(color: white),
    bodyMedium: TextStyle(color: white),
    bodySmall: TextStyle(color: white),
  ),

  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: neutral_500.withAlpha((100)),

  ),

  iconTheme: IconThemeData(color: white, size: 24),
);

class AppGradientTheme extends ThemeExtension<AppGradientTheme> {
  final LinearGradient primaryGradient;
  final LinearGradient secondaryGradient;
  final LinearGradient backgroundGradient;

  const AppGradientTheme({
    required this.primaryGradient,
    required this.secondaryGradient,
    required this.backgroundGradient,
  });

  @override
  ThemeExtension<AppGradientTheme> copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? secondaryGradient,
    LinearGradient? backgroundGradient,
  }) {
    return AppGradientTheme(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      secondaryGradient: secondaryGradient ?? this.secondaryGradient,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  ThemeExtension<AppGradientTheme> lerp(
    ThemeExtension<AppGradientTheme>? other,
    double t,
  ) {
    if (other is! AppGradientTheme) {
      return this;
    }
    return AppGradientTheme(
      primaryGradient: LinearGradient.lerp(
        primaryGradient,
        other.primaryGradient,
        t,
      )!,
      secondaryGradient: LinearGradient.lerp(
        secondaryGradient,
        other.secondaryGradient,
        t,
      )!,
      backgroundGradient: LinearGradient.lerp(
        backgroundGradient,
        other.backgroundGradient,
        t,
      )!,
    );
  }
}
