import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/providers/lang_service.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final LanguageService _languageService = getIt<LanguageService>();
  final AuthService _authService = getIt<AuthService>();
  final UserStorageService _userStorageService = getIt<UserStorageService>();
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final locale = await _languageService.getCurrentLanguage();
    if (mounted) {
      setState(() {
        _currentLanguage = locale.languageCode;
      });
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    setState(() {
      _currentLanguage = languageCode;
    });
    
    // Cambiar idioma localmente
    await _languageService.changeLanguage(Locale(languageCode));
    
    // Si el usuario está logueado, actualizar en el servidor
    try {
      final token = await _userStorageService.getJWTToken();
      if (token != null) {
        debugPrint('🌐 Actualizando idioma en el servidor: $languageCode');
        await _authService.updateLanguage(
          token: token,
          language: languageCode,
        );
        debugPrint('✅ Idioma actualizado en el servidor');
      } else {
        debugPrint('⚠️ Usuario no logueado, idioma solo cambiado localmente');
      }
    } catch (e) {
      debugPrint('⚠️ Error al actualizar idioma en el servidor: $e');
      // Continuar aunque falle el API, el cambio local ya se hizo
    }
    
    if (mounted) {
      final localizations = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'en' 
              ? localizations['settings']['languageSelector']['languageChangedToEnglish']
              : localizations['settings']['languageSelector']['languageChangedToSpanish']
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!['settings']['languageSelector']['language'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLanguageButton(
                label: AppLocalizations.of(context)!['settings']['languageSelector']['english'],
                languageCode: 'en',
                isSelected: _currentLanguage == 'en',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLanguageButton(
                label: AppLocalizations.of(context)!['settings']['languageSelector']['spanish'],
                languageCode: 'es',
                isSelected: _currentLanguage == 'es',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageButton({
    required String label,
    required String languageCode,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => _changeLanguage(languageCode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF4A5568) 
            : const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
              ? Colors.blue.withOpacity(0.5) 
              : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
