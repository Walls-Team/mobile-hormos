import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/acceptdevice/pages/accept_device.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/verify_email.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/forgot_password.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/features/faqs/faqs.dart';
import 'package:genius_hormo/features/settings/settings.dart';
import 'package:genius_hormo/features/stats/stats.dart';
import 'package:genius_hormo/features/store/store.dart';
import 'package:genius_hormo/features/terms_and_conditions/terms_and_conditions.dart';
import 'package:genius_hormo/welcome.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthService _authService = GetIt.instance<AuthService>();

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: publicRoutes.home,
    routes: [
      // RUTAS PÚBLICAS
      GoRoute(
        path: publicRoutes.home,
        name: 'home',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: publicRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: publicRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: publicRoutes.forgotPassword,
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // RUTAS PRIVADAS
      GoRoute(
        path: privateRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: privateRoutes.stats,
        name: 'stats',
        builder: (context, state) =>  StatsScreen(),
      ),
      GoRoute(
        path: privateRoutes.store,
        name: 'store',
        builder: (context, state) => const StoreScreen(),
      ),
      GoRoute(
        path: privateRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: privateRoutes.faqs,
        name: 'faqs',
        builder: (context, state) => const FaqsScreen(),
      ),
      GoRoute(
        path: privateRoutes.termsAndConditions,
        name: 'terms_and_conditions',
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),

      // RUTAS PRIVADAS CON PARÁMETROS (usando extra para seguridad)
      GoRoute(
        path: '/auth/verify_email', // Sin parámetro en la URL
        name: 'verify_email',
        builder: (context, state) {
          final email = state.extra as String; // Recibe el email via extra
          return VerificationCodeScreen(email: email);
        },
      ),

      GoRoute(
        path: privateRoutes.acceptDevice, // Sin parámetro en la URL
        name: 'acceptdevice',
        builder: (context, state) {
          final providerSlug = state.uri.queryParameters['provider_slug'];
          final userId = state.uri.queryParameters['user_id'];

          print('se ejecuto la ruta deseada');
          print(state);
          print(context);
          // final email = state.extra as String; // Recibe el email via extra
          return AcceptDeviceScreen();
        },
      ),

      // GoRoute(
      //   path: '/auth/reset_password', // Sin parámetro en la URL
      //   name: 'reset_password',
      //   builder: (context, state) {
      //     final token = state.extra as String; // Recibe el token via extra
      //     // return ResetPasswordForm(token: token);
      //   },
      // ),
    ],

    // MÉTODO REDIRECT MEJORADO
    redirect: (context, state) async {
      // Verificar estado de autenticación
      final bool isLoggedIn = false;
      // final bool isLoggedIn = await _authService.isLoggedIn();

      // Determinar el tipo de ruta actual
      final currentLocation = state.matchedLocation;
      final bool isPublicRoute = _isPublicRoute(currentLocation);
      final bool isPrivateRoute = _isPrivateRoute(currentLocation);
      final bool isAuthRoute = _isAuthRoute(currentLocation);

      // CASO 1: Usuario NO autenticado intentando acceder a ruta privada
      if (!isLoggedIn && isPrivateRoute) {
        return publicRoutes.login;
      }

      // CASO 2: Usuario autenticado intentando acceder a rutas de auth (login, register, etc.)
      if (isLoggedIn && isAuthRoute) {
        return privateRoutes.dashboard;
      }

      // CASO 3: Usuario autenticado en la página de inicio → redirigir a dashboard
      if (isLoggedIn && currentLocation == publicRoutes.home) {
        return privateRoutes.dashboard;
      }

      // CASO 4: Acceso directo a rutas con parámetros sensibles → bloquear
      if (_isDirectAccessToSensitiveRoute(state)) {
        return publicRoutes.home;
      }

      // No hay redirección necesaria
      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(publicRoutes.home),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    ),
  );

  // MÉTODOS AUXILIARES
  bool _isPublicRoute(String location) {
    return location == publicRoutes.home ||
        location == publicRoutes.login ||
        location == publicRoutes.register ||
        location == publicRoutes.forgotPassword;
  }

  bool _isPrivateRoute(String location) {
    return location == privateRoutes.dashboard ||
        location == privateRoutes.stats ||
        location == privateRoutes.store ||
        location == privateRoutes.settings ||
        location == privateRoutes.faqs ||
        location == privateRoutes.termsAndConditions;
  }

  bool _isAuthRoute(String location) {
    return location == publicRoutes.login ||
        location == publicRoutes.register ||
        location == publicRoutes.forgotPassword;
  }

  bool _isDirectAccessToSensitiveRoute(GoRouterState state) {
    // Bloquear acceso directo a rutas que deberían recibir parámetros via extra
    if (state.matchedLocation == '/auth/verify_email' && state.extra == null) {
      return true;
    }
    if (state.matchedLocation == '/auth/reset_password' &&
        state.extra == null) {
      return true;
    }
    return false;
  }

  GoRouter config() {
    return _router;
  }
}
