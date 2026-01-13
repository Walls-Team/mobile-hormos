import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/core/auth/auth_redirect_service.dart';
import 'package:genius_hormo/features/acceptdevice/pages/accept_device.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/verify_email.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/forgot_password.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/payments/pages/payment_success_screen.dart';
import 'package:genius_hormo/features/payments/pages/payment_cancelled_screen.dart';
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
  // Singleton pattern para evitar recreación
  static AppRouter? _instance;
  factory AppRouter() {
    _instance ??= AppRouter._internal();
    return _instance!;
  }
  
  AppRouter._internal();
  
  final AuthService _authService = GetIt.instance<AuthService>();
  
  // Router estático que nunca se recrea
  static GoRouter? _cachedRouter;
  
  GoRouter get router {
    if (_cachedRouter != null) {
      return _cachedRouter!;
    }
    
    _cachedRouter = GoRouter(
      initialLocation: publicRoutes.home,
      debugLogDiagnostics: false,
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
      // FAQs se abre con Navigator.push() tradicional, NO con GoRouter

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
      
      // Rutas para pagos con Stripe
      GoRoute(
        path: privateRoutes.stripePaymentSuccess,
        name: 'stripe_payment_success',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return PaymentSuccessScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: privateRoutes.stripePaymentCancel,
        name: 'stripe_payment_cancel',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return PaymentCancelledScreen(sessionId: sessionId);
        },
      ),
      
      // Rutas ADICIONALES para Stripe sin el prefijo /stripe
      // Esto captura deeplinks que llegan como /success en lugar de /stripe/success
      GoRoute(
        path: '/success',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          print('🟢 Capturando deeplink directo /success con session_id: $sessionId');
          return PaymentSuccessScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/cancel',
        builder: (context, state) {
          final sessionId = state.uri.queryParameters['session_id'];
          return PaymentCancelledScreen(sessionId: sessionId);
        },
      ),
    ],

    // MÉTODO REDIRECT FUNCIONAL - Maneja autenticación sin Navigator locks
    redirect: (context, state) async {
      final authRedirectService = AuthRedirectService();
      return await authRedirectService.handleRedirect(state);
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
    
    return _cachedRouter!;
  }

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
        location == privateRoutes.settings;
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
}
