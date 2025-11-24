import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  final StreamController<Locale> _localeController = StreamController<Locale>.broadcast();
  
  // Stream público para escuchar cambios de idioma
  Stream<Locale> get currentLocale => _localeController.stream;
  
  // Inicializar el servicio
  Future<void> init() async {
    // Cargar el idioma guardado o usar inglés por defecto
    final savedLanguage = await _getSavedLanguage();
    _localeController.add(savedLanguage);
  }
  
  // Cambiar idioma
  Future<void> changeLanguage(Locale newLocale) async {
    await _saveLanguage(newLocale);
    _localeController.add(newLocale);
  }
  
  // Obtener idioma actual
  Future<Locale> getCurrentLanguage() async {
    return await _getSavedLanguage();
  }
  
  // Guardar idioma en SharedPreferences
  Future<void> _saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
  
  // Obtener idioma guardado
  Future<Locale> _getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    // Si no hay idioma guardado, usar el idioma del sistema
    if (languageCode == null) {
      final systemLocale = ui.window.locale;
      final systemLanguage = systemLocale.languageCode;
      
      // Verificar si el idioma del sistema está soportado
      final supportedCodes = ['en', 'es'];
      if (supportedCodes.contains(systemLanguage)) {
        debugPrint('🌐 Idioma del sistema detectado: $systemLanguage');
        return Locale(systemLanguage);
      }
      
      // Si no está soportado, usar inglés por defecto
      debugPrint('🌐 Idioma del sistema no soportado, usando inglés por defecto');
      return const Locale('en');
    }
    
    return Locale(languageCode);
  }
  
  // Lista de idiomas soportados
  List<Map<String, dynamic>> get supportedLanguages => [
    {
      'code': 'en',
      'name': 'English',
      'locale': const Locale('en'),
    },
    {
      'code': 'es', 
      'name': 'Español',
      'locale': const Locale('es'),
    },
  ];
  
  void dispose() {
    _localeController.close();
  }
}