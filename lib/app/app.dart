import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_hormo/app/routes.dart';
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_data.dart';
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_service.dart';
import 'package:genius_hormo/core/di/dependency_injection.dart';
import 'package:genius_hormo/core/navigation/navigation_service.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/providers/lang_service.dart';
import 'package:genius_hormo/theme/theme.dart';


class GeniusHormoApp extends StatefulWidget {
  const GeniusHormoApp({super.key});

  @override
  State<GeniusHormoApp> createState() => _GeniusHormoAppState();
}

class _GeniusHormoAppState extends State<GeniusHormoApp> {
  final GeniusHormoDeepLinkService _deepLinkService = getIt<GeniusHormoDeepLinkService>();
  final NavigationService _navigationService = getIt<NavigationService>();
  final LanguageService _languageService = getIt<LanguageService>();
  final AppRouter _appRouter = AppRouter();
  
  StreamSubscription<GeniusHormoDeepLinkData>? _deepLinkSubscription;
  StreamSubscription<Locale>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _languageService.init();
      await _initializeDeepLinks();
      
      _logInfo('Aplicación GeniusHormo inicializada correctamente');
    } catch (e) {
      _logError('Error inicializando la aplicación: $e');
    }
  }

  Future<void> _initializeDeepLinks() async {
    try {
      await _deepLinkService.init();
      
      _deepLinkSubscription = _deepLinkService.deepLinkStream.listen(
        _navigationService.handleDeepLink,
        onError: (error) {
          _logError('Error en stream de deep links: $error');
        }
      );
      
      _logInfo('Deep links inicializados correctamente');
    } catch (e) {
      _logError('Error inicializando deep links: $e');
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _languageSubscription?.cancel();
    _deepLinkService.dispose();
    _navigationService.dispose();
    _languageService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Locale>(
      stream: _languageService.currentLocale,
      initialData: const Locale('en'),
      builder: (context, snapshot) {
        final currentLocale = snapshot.data ?? const Locale('en');
        
        return MaterialApp.router(
          title: 'GeniusHormo',
          routerConfig: _appRouter.config(),
          debugShowCheckedModeBanner: false,
          
          // ✅ CONFIGURACIÓN COMPLETA Y CORRECTA DE LOCALIZATIONS
          locale: currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,        // Tus traducciones personalizadas
            // GlobalMaterialLocalizations.delegate, // ✅ MATERIAL LOCALIZATIONS (IMPORTANTE)
            // GlobalCupertinoLocalizations.delegate, // ✅ CUpertino localizations  
            // GlobalWidgetsLocalizations.delegate, // ✅ Widgets localizations
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('es', ''), // Spanish
          ],
          
          // ✅ CONFIGURACIÓN ADICIONAL PARA MATERIAL APP
          theme: theme,
        );
      },
    );
  }

  void _logInfo(String message) {
    print('🚀 GeniusHormoApp: $message');
  }

  void _logError(String message) {
    print('❌ GeniusHormoApp: $message');
  }
}
