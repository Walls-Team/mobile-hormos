import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/verify_email.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/views/auth/pages/forgot_password.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';

import 'package:genius_hormo/views/terms_and_conditions.dart';
import 'package:genius_hormo/views/welcome.dart';
import 'package:genius_hormo/views/faqs/faqs.dart';
import 'package:genius_hormo/views/settings/settings.dart';
import 'package:genius_hormo/views/store/store.dart';
import 'package:go_router/go_router.dart';

import 'package:genius_hormo/views/auth/pages/verification_code.dart' hide VerificationCodeScreen;
import 'package:genius_hormo/views/auth/pages/reset_password.dart';
import 'route_names.dart';

class AppRouter {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      // HOME
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const WelcomeScreen(),
      ),

      //AUTH
      
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: RouteNames.verifyEmail,
        name: 'verify_email',
        builder: (context, state) {

          final email = state.pathParameters['email']!;

          print(email);

          return VerificationCodeScreen(email: email);
        },
      ),

      // TERMS AND CONDITIONS
      // GoRoute(
      //   path: RouteNames.termsAndConditions,
      //   name: RouteNames.termsAndConditions,
      //   builder: (context, state) => const TermsAndConditionsScreen(),
      // ),


      // // STATS
      // GoRoute(
      //   path: RouteNames.stats,
      //   name: RouteNames.stats,
      //   builder: (context, state) => const StatsScreen(),
      // ),

      // WELCOME
      // GoRoute(
      //   path: RouteNames.dashboard,
      //   name: RouteNames.dashboard,
      //   builder: (context, state) => const HomeScreen(),
      // ),

      // STORE
      // GoRoute(
      //   path: RouteNames.store,
      //   name: RouteNames.store,
      //   builder: (context, state) => const StoreScreen(),
      // ),

      // SETTINGS
      // GoRoute(
      //   path: RouteNames.settings,
      //   name: RouteNames.settings,
      //   builder: (context, state) => const SettingsScreen(),
      // ),

      // // FAQs
      // GoRoute(
      //   path: RouteNames.faqs,
      //   name: RouteNames.faqs,
      //   builder: (context, state) => const FaqsScreen(),
      // ),

      // AUTH GROUP - Rutas de autenticación

      // GoRoute(
      //   path: RouteNames.resetPassword,
      //   name: RouteNames.resetPassword,
      //   builder: (context, state) => const ResetPasswordScreen(),
      // ),
      // GoRoute(
      //   path: RouteNames.forgotPassword,
      //   name: RouteNames.forgotPassword,
      //   builder: (context, state) => ForgotPasswordScreen(),
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
