import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
  
  // Usar el singleton de AppRouter
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
      _setupLanguageListener();
      
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

  void _setupLanguageListener() {
    _languageSubscription = _languageService.currentLocale.listen((locale) {
      _logInfo('Idioma cambiado a: ${locale.languageCode}');
    });
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
          routerConfig: _appRouter.router,
          debugShowCheckedModeBanner: false,
          
          // ✅ CONFIGURACIÓN COMPLETA Y CORRECTA DE LOCALIZATIONS
          locale: currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,        // Tus traducciones personalizadas
            GlobalMaterialLocalizations.delegate, // ✅ MATERIAL LOCALIZATIONS (IMPORTANTE)
            GlobalCupertinoLocalizations.delegate, // ✅ CUPERTINO LOCALIZATIONS  
            GlobalWidgetsLocalizations.delegate, // ✅ WIDGETS LOCALIZATIONS
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('es', ''), // Spanish
          ],
          
          // ✅ CONFIGURACIÓN ADICIONAL PARA MATERIAL APP
          theme: theme,
          localeResolutionCallback: (locale, supportedLocales) {
            // Si el locale es nulo, devolver el por defecto
            if (locale == null) {
              return const Locale('en');
            }

            // Buscar si el locale está soportado exactamente
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }

            // Si no se encuentra, devolver el por defecto
            return const Locale('en');
          },
          
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Previene escalado de texto no deseado
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }

  void _logInfo(String message) {
    debugPrint('🚀 GeniusHormoApp: $message');
  }

  void _logError(String message) {
    debugPrint('❌ GeniusHormoApp: $message');
  }
}