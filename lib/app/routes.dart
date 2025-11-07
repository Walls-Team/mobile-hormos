import 'package:flutter/material.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/views/auth/forgot_password.dart';
import 'package:genius_hormo/views/auth/login.dart';
import 'package:genius_hormo/views/auth/register.dart';

import 'package:genius_hormo/views/auth/terms_and_conditions.dart';
import 'package:genius_hormo/views/auth/welcome.dart';
import 'package:genius_hormo/views/faqs/faqs.dart';
import 'package:genius_hormo/views/settings/settings.dart';
import 'package:genius_hormo/views/store/store.dart';
import 'package:go_router/go_router.dart';

import 'package:genius_hormo/views/auth/verification_code.dart';
import 'package:genius_hormo/views/auth/reset_password.dart';
import 'route_names.dart';

class AppRouter {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      // HOME
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // TERMS AND CONDITIONS
      GoRoute(
        path: RouteNames.termsAndConditions,
        name: RouteNames.termsAndConditions,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),

      // DASHBOARD
      GoRoute(
        path: RouteNames.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const HomeScreen(),
      ),

      // // STATS
      // GoRoute(
      //   path: RouteNames.stats,
      //   name: RouteNames.stats,
      //   builder: (context, state) => const StatsScreen(),
      // ),

      // STORE
      GoRoute(
        path: RouteNames.store,
        name: RouteNames.store,
        builder: (context, state) => const StoreScreen(),
      ),

      // SETTINGS
      GoRoute(
        path: RouteNames.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // FAQs
      GoRoute(
        path: RouteNames.faqs,
        name: RouteNames.faqs,
        builder: (context, state) => const FaqsScreen(),
      ),

      // AUTH GROUP - Rutas de autenticación
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // GoRoute(
      //   path: RouteNames.resetPassword,
      //   name: RouteNames.resetPassword,
      //   builder: (context, state) => const ResetPasswordScreen(),
      // ),

      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => ForgotPasswordScreen(),
      ),

      // GoRoute(
      //   path: RouteNames.verificateEmailCode,
      //   name: RouteNames.verificateEmailCode,
      //   builder: (context, state) {
      //     final email = state.uri.queryParameters['email'];
      //     final action = state.uri.queryParameters['action'];


      //     return VerificationCodeScreen(
      //       email: email,
      //       action: action,
      //     );
      //   },
      // ),
    ],

    // Redirección basada en estado de autenticación (opcional)
    redirect: (context, state) {
      // Aquí puedes agregar lógica de redirección basada en autenticación
      // Por ejemplo:
      // final isAuthenticated = AuthService.isAuthenticated();
      // final goingToAuth = state.matchedLocation.contains('/auth');
      
      // if (!isAuthenticated && !goingToAuth) {
      //   return RouteNames.login;
      // }
      
      // if (isAuthenticated && goingToAuth) {
      //   return RouteNames.dashboard;
      // }
      
      return null;
    },

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
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
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    ),
  );

  GoRouter config() {
    return _router;
  }
}