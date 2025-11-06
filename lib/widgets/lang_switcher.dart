import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String languageCode) {
        localeProvider.setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('English'),
              if (localeProvider.currentLanguage == 'en')
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'es',
          child: Row(
            children: [
              Text('Español'),
              if (localeProvider.currentLanguage == 'es')
                const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// Alternativa: Botón simple para cambiar idioma
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () {
        localeProvider.toggleLanguage();
      },
      tooltip: 'Change Language (${localeProvider.displayLanguage})',
    );
  }
}