import 'package:flutter/material.dart';
import 'package:genius_hormo/core/di/dependency_injection.dart';
import 'package:genius_hormo/providers/lang_service.dart';

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final LanguageService _languageService = getIt<LanguageService>();
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
    
    await _languageService.changeLanguage(Locale(languageCode));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            languageCode == 'en' 
              ? 'Language changed to English' 
              : 'Idioma cambiado a Español'
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
        const Text(
          'Language',
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
                label: 'English',
                languageCode: 'en',
                isSelected: _currentLanguage == 'en',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLanguageButton(
                label: 'Spanish',
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
