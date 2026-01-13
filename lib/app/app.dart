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
import 'package:genius_hormo/providers/subscription_provider.dart';
import 'package:provider/provider.dart';
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
  
  // Obtener el provider de forma lazy para evitar problemas de inicialización
  SubscriptionProvider get _subscriptionProvider => getIt<SubscriptionProvider>();
  
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
      
      // Consultar el plan actual del usuario
      await _initializeSubscription();
      
      _logInfo('Aplicación GeniusHormo inicializada correctamente');
    } catch (e) {
      _logError('Error inicializando la aplicación: $e');
    }
  }
  
  /// Inicializa la consulta del plan de suscripción
  Future<void> _initializeSubscription() async {
    try {
      _logInfo('++++++++++++++++++++++++++++++Consultando plan de suscripción...');
      await _subscriptionProvider.fetchCurrentPlan();
      
      if (_subscriptionProvider.hasActivePlan) {
        _logInfo('Plan activo: ${_subscriptionProvider.currentPlan!.plan_details?.title ?? "Plan Desconocido"}');
      } else {
        _logInfo('Usuario sin plan activo');
      }
    } catch (e) {
      _logError('Error consultando plan de suscripción: $e');
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
    // Obtener el provider aquí para asegurar que GetIt ya está inicializado
    final subscriptionProvider = getIt<SubscriptionProvider>();
    
    return ChangeNotifierProvider<SubscriptionProvider>.value(
      value: subscriptionProvider,
      child: StreamBuilder<Locale>(
        stream: _languageService.currentLocale,
        initialData: const Locale('en'),
        builder: (context, snapshot) {
          final currentLocale = snapshot.data ?? const Locale('en');
          
          return MaterialApp.router(
            title: 'GeniusHormo',
            routerConfig: _appRouter.router,
            debugShowCheckedModeBanner: false,
            
            // CONFIGURACIÓN COMPLETA Y CORRECTA DE LOCALIZATIONS
            locale: currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,        // Tus traducciones personalizadas
              GlobalMaterialLocalizations.delegate, // MATERIAL LOCALIZATIONS (IMPORTANTE)
              GlobalCupertinoLocalizations.delegate, // CUPERTINO LOCALIZATIONS  
              GlobalWidgetsLocalizations.delegate, // WIDGETS LOCALIZATIONS
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('es', ''), // Spanish
            ],
            
            // CONFIGURACIÓN ADICIONAL PARA MATERIAL APP
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
      ),
    );
  }

  void _logInfo(String message) {
    debugPrint(' GeniusHormoApp: $message');
  }

  void _logError(String message) {
    debugPrint('❌ GeniusHormoApp: $message');
  }
}