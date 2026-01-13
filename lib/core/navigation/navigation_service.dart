import 'package:genius_hormo/core/deep_link/deep_link_mapper.dart';
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_data.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final DeepLinkMapper _deepLinkMapper;

  NavigationService() {
    _deepLinkMapper = DeepLinkMapper(navigatorKey: navigatorKey);
  }

  /// Maneja los deep links recibidos y los convierte en navegación
  void handleDeepLink(GeniusHormoDeepLinkData deepLinkData) {
    print(deepLinkData.fragment);

    // Manejo especial para Stripe
    if ((deepLinkData.host == 'stripe' && 
         deepLinkData.segments.isNotEmpty && 
         (deepLinkData.segments[0] == 'success' || deepLinkData.segments[0] == 'cancel')) ||
        (deepLinkData.segments.length >= 2 && 
         deepLinkData.segments[0] == 'stripe' && 
         (deepLinkData.segments[1] == 'success' || deepLinkData.segments[1] == 'cancel'))) {
      
      // Determinar la ruta correcta para Stripe
      String stripePath;
      if (deepLinkData.host == 'stripe') {
        stripePath = deepLinkData.segments[0] == 'success' ? '/stripe/success' : '/stripe/cancel';
      } else {
        stripePath = deepLinkData.segments[1] == 'success' ? '/stripe/success' : '/stripe/cancel';
      }
      
      print('✅ Redirigiendo directamente a: $stripePath');
      _navigate(stripePath, {
        if (deepLinkData.getQueryParam('session_id') != null) 
          'session_id': deepLinkData.getQueryParam('session_id')!,
      });
      return;
    }
    
    // Procesamiento normal para otros deeplinks
    final routeConfig = _deepLinkMapper.mapDeepLinkToRoute(deepLinkData);

    print(deepLinkData.fragment);
    
    if (routeConfig != null) {
      _navigateToRoute(routeConfig);
    } else {
      _logError('No se pudo mapear el deep link: $deepLinkData');
    }
  }

  /// Navega a la ruta configurada desde un deep link
  void _navigateToRoute(DeepLinkRouteConfig routeConfig) {
    try {
      // Si el contexto de la ruta es nulo, intentamos usar el contexto global
      final context = routeConfig.context ?? navigatorKey.currentContext;
      
      if (context == null) {
        _logError('No hay contexto disponible para navegación');
        // Intentamos usar _navigate con el path directamente
        _navigate(routeConfig.path, routeConfig.queryParameters);
        return;
      }
      
      final GoRouter? router = GoRouter.of(context);
      if (router != null) {
        if (routeConfig.queryParameters.isNotEmpty) {
          final uri = Uri(
            path: routeConfig.path, 
            queryParameters: routeConfig.queryParameters
          );
          router.go(uri.toString());
          _logInfo('Navegando a: ${uri.toString()}');
        } else {
          router.go(routeConfig.path);
          _logInfo('Navegando a: ${routeConfig.path}');
        }
      } else {
        _logError('Router no disponible para navegación');
        // Si no hay router, intentamos usar _navigate como fallback
        _navigate(routeConfig.path, routeConfig.queryParameters);
      }
    } catch (e) {
      _logError('Error en navegación: $e');
      // En caso de error, intentamos usar _navigate como último recurso
      _navigate(routeConfig.path, routeConfig.queryParameters);
    }
  }

  /// Navega a la pantalla de inicio
  void navigateToHome() {
    _navigate('/');
  }

  /// Navega a los términos y condiciones
  void navigateToTermsAndConditions() {
    _navigate('/terms_and_conditions');
  }

  /// Navega al dashboard
  void navigateToDashboard() {
    _navigate('/dashboard');
  }

  /// Navega a las estadísticas
  void navigateToStats() {
    _navigate('/stats');
  }

  /// Navega a la tienda
  void navigateToStore() {
    _navigate('/store');
  }

  /// Navega a configuraciones
  void navigateToSettings() {
    _navigate('/settings');
  }

  /// Navega a preguntas frecuentes
  void navigateToFaqs() {
    _navigate('/faqs');
  }

  /// Navega al login
  void navigateToLogin() {
    _navigate('/auth/login');
  }

  /// Navega al registro
  void navigateToRegister() {
    _navigate('/auth/register');
  }

  /// Navega a resetear contraseña
  void navigateToResetPassword() {
    _navigate('/auth/reset_password');
  }

  /// Navega a olvidar contraseña
  void navigateToForgotPassword() {
    _navigate('/auth/forgot_password');
  }

  /// Navega a verificación de email con parámetros opcionales
  void navigateToEmailVerification({String? email, String? action}) {
    final params = <String, String>{};
    if (email != null) params['email'] = email;
    if (action != null) params['action'] = action;
    
    _navigate('/auth/code_validation', params);
  }

  // ========== MÉTODOS DE NAVEGACIÓN CON GO_ROUTER ==========

  /// Navega usando GoRouter con nombre de ruta
  void goNamed(String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        GoRouter.of(context).goNamed(
          routeName,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
        );
        _logInfo('Navegando por nombre a: $routeName');
      } catch (e) {
        _logError('Error navegando por nombre: $e');
      }
    }
  }

  /// Navega usando GoRouter con path
  void go(String path, {Map<String, String> queryParameters = const {}}) {
    _navigate(path, queryParameters);
  }

  /// Navega hacia atrás
  void goBack() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        GoRouter.of(context).pop();
      } catch (e) {
        _logError('Error navegando hacia atrás: $e');
      }
    }
  }

  // ========== MÉTODOS DE UTILIDAD ==========

  /// Método interno para navegación
  void _navigate(String path, [Map<String, String> queryParameters = const {}]) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final router = GoRouter.of(context);
        if (queryParameters.isNotEmpty) {
          final uri = Uri(path: path, queryParameters: queryParameters);
          router.go(uri.toString());
        } else {
          router.go(path);
        }
      } catch (e) {
        _logError('Error en navegación interna: $e - Path: $path');
      }
    } else {
      _logError('Contexto no disponible para navegación');
    }
  }

  /// Verifica si puede navegar hacia atrás
  bool canPop() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return GoRouter.of(context).canPop();
    }
    return false;
  }

  /// ✅ CORREGIDO: Obtiene la ruta actual
  String? get currentLocation {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        // Opción 1: Usar GoRouterState (recomendado)
        final state = GoRouterState.of(context);
        return state.uri.toString();
        
        // Opción 2: Usar GoRouter directamente
        // return GoRouter.of(context).state.uri.toString();
        
      } catch (e) {
        _logError('Error obteniendo ubicación actual: $e');
      }
    }
    return null;
  }

  /// ✅ CORREGIDO: Obtiene los parámetros de consulta actuales
  Map<String, String> get currentQueryParameters {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final state = GoRouterState.of(context);
        return state.uri.queryParameters;
      } catch (e) {
        _logError('Error obteniendo parámetros de consulta: $e');
      }
    }
    return {};
  }

  /// ✅ CORREGIDO: Obtiene los parámetros de path actuales
  Map<String, String> get currentPathParameters {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final state = GoRouterState.of(context);
        return state.pathParameters;
      } catch (e) {
        _logError('Error obteniendo parámetros de path: $e');
      }
    }
    return {};
  }

  /// ✅ NUEVO: Obtiene la URI completa actual
  Uri? get currentUri {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final state = GoRouterState.of(context);
        return state.uri;
      } catch (e) {
        _logError('Error obteniendo URI actual: $e');
      }
    }
    return null;
  }

  /// ✅ NUEVO: Obtiene el path actual (sin query parameters)
  String? get currentPath {
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final state = GoRouterState.of(context);
        return state.uri.path;
      } catch (e) {
        _logError('Error obteniendo path actual: $e');
      }
    }
    return null;
  }

  /// Método para obtener el contexto actual
  BuildContext? get currentContext => navigatorKey.currentContext;

  // ========== LOGGING ==========

  void _logInfo(String message) {
    print('🧭 NavigationService: $message');
  }

  void _logError(String message) {
    print('❌ NavigationService: $message');
  }

  /// Dispose del servicio
  void dispose() {
    _logInfo('NavigationService disposed');
  }
}

/// Configuración de ruta para deep links
class DeepLinkRouteConfig {
  final BuildContext? context; 
  final String path;
  final Map<String, String> queryParameters;

  DeepLinkRouteConfig({
    this.context, 
    required this.path,
    this.queryParameters = const {},
  });

  @override
  String toString() {
    return 'DeepLinkRouteConfig{path: $path, queryParameters: $queryParameters}';
  }
}