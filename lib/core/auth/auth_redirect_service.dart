import 'package:flutter/foundation.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/providers/subscription_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Servicio para manejar redirects de autenticación sin causar Navigator locks
class AuthRedirectService {
  static final AuthRedirectService _instance = AuthRedirectService._internal();

  factory AuthRedirectService() {
    return _instance;
  }

  AuthRedirectService._internal();

  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  final SubscriptionProvider _subscriptionProvider = GetIt.instance<SubscriptionProvider>();

  /// Determinar si una ruta es pública
  bool _isPublicRoute(String location) {
    return location == publicRoutes.home ||
        location == publicRoutes.login ||
        location == publicRoutes.register ||
        location == publicRoutes.forgotPassword ||
        location.startsWith('/auth/');
  }

  /// Determinar si una ruta es privada
  bool _isPrivateRoute(String location) {
    return location == privateRoutes.dashboard ||
        location == privateRoutes.stats ||
        location == privateRoutes.store ||
        location == privateRoutes.settings;
  }
  
  /// Determinar si una ruta requiere suscripción activa
  bool _requiresSubscription(String location) {
    return location == privateRoutes.dashboard ||
        location == privateRoutes.stats;
  }

  /// Lógica principal de redirect
  /// Se ejecuta de forma síncrona para evitar locks
  Future<String?> handleRedirect(GoRouterState state) async {
    try {
      final currentLocation = state.matchedLocation;
      final urlPath = state.uri.path;
      final rawUri = state.uri.toString();
      
      debugPrint('🔄 === REDIRECT DEBUG === ');
      debugPrint('🔄 Evaluando redirect para: $currentLocation');
      debugPrint('🔄 URI path completo: $urlPath');
      debugPrint('🔄 URI completo: $rawUri');
      debugPrint('🔄 state info: ${state.fullPath}, params: ${state.pathParameters}, query: ${state.uri.queryParameters}');

      // Verificar si hay token
      final token = await _userStorageService.getJWTToken();
      final hasToken = token != null && token.isNotEmpty;

      debugPrint('🔐 Token presente: $hasToken');
      
      // CASO ESPECIAL: Redireccionar rutas de Stripe incorrectas
      if (currentLocation == '/success' || urlPath == '/success' || rawUri.contains('/success')) {
        debugPrint('✅ REDIRIGIENDO /success a /stripe/success');
        return '/stripe/success';
      }
      if (currentLocation == '/cancel' || urlPath == '/cancel' || rawUri.contains('/cancel')) {
        debugPrint('✅ REDIRIGIENDO /cancel a /stripe/cancel');
        return '/stripe/cancel';
      }
      
      // También verificar versiones sin barra inicial
      if (currentLocation == 'success' || urlPath == 'success') {
        debugPrint('✅ REDIRIGIENDO success (sin barra) a /stripe/success');
        return '/stripe/success';
      }
      if (currentLocation == 'cancel' || urlPath == 'cancel') {
        debugPrint('✅ REDIRIGIENDO cancel (sin barra) a /stripe/cancel');
        return '/stripe/cancel';
      }

      // CASO 1: Usuario NO autenticado intentando acceder a ruta privada
      if (!hasToken && _isPrivateRoute(currentLocation)) {
        debugPrint('⛔ Acceso denegado a ruta privada sin token → Redirigiendo a login');
        return publicRoutes.login;
      }

      // CASO 2: Usuario autenticado intentando acceder a rutas de auth
      if (hasToken && (currentLocation == publicRoutes.login || 
                       currentLocation == publicRoutes.register ||
                       currentLocation == publicRoutes.forgotPassword)) {
        debugPrint('✅ Usuario autenticado en ruta de auth → Redirigiendo a dashboard');
        return privateRoutes.dashboard;
      }
      
      // NOTA: Ya no redirigimos a Settings cuando no hay plan activo
      // En su lugar, Dashboard y Stats muestran sus propios headers informativos
      // cuando el usuario no tiene dispositivo conectado o plan activo

      // CASO 3: Usuario autenticado en la página de inicio → redirigir a dashboard
      if (hasToken && currentLocation == publicRoutes.home) {
        debugPrint('✅ Usuario autenticado en home → Redirigiendo a dashboard');
        return privateRoutes.dashboard;
      }

      // CASO 4: Usuario no autenticado en home → mantener en home (WelcomeScreen)
      if (!hasToken && currentLocation == publicRoutes.home) {
        debugPrint('ℹ️ Usuario no autenticado en home → Mantener en home');
        return null;
      }

      // No hay redirección necesaria
      debugPrint('✅ No hay redirección necesaria');
      return null;
    } catch (e) {
      debugPrint('❌ Error en handleRedirect: $e');
      return null;
    }
  }
}
