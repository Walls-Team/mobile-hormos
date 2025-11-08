import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/verify_email.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/forgot_password.dart';
import 'package:genius_hormo/features/auth/services/auth_provider.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/views/faqs/faqs.dart';
import 'package:genius_hormo/views/settings/settings.dart';
import 'package:genius_hormo/views/stats/stats.dart';
import 'package:genius_hormo/views/store/store.dart';
import 'package:genius_hormo/views/terms_and_conditions.dart';
import 'package:genius_hormo/views/welcome.dart';
import 'package:go_router/go_router.dart';

import 'package:go_router/go_router.dart';

// class AppRouter {
//   final AuthService _authService = AuthService();

//   GoRouter get router => _router;

//   late final GoRouter _router = GoRouter(
//     initialLocation: publicRoutes.home,
//     routes: [
//       GoRoute(
//         path: publicRoutes.home,
//         name: 'home',
//         builder: (context, state) => const WelcomeScreen(),
//       ),

//       GoRoute(
//         path: publicRoutes.login,
//         name: 'login',
//         builder: (context, state) => const LoginScreen(),
//       ),

//       GoRoute(
//         path: publicRoutes.register,
//         name: 'register',
//         builder: (context, state) => const RegisterScreen(),
//       ),

//       GoRoute(
//         path: publicRoutes.forgotPassword,
//         name: 'forgot-password',
//         builder: (context, state) => const ForgotPasswordScreen(),
//       ),

//       GoRoute(
//         path: privateRoutes.dashboard,
//         name: 'dashboard',
//         builder: (context, state) => const HomeScreen(),
//       ),

//       GoRoute(
//         path: privateRoutes.stats,
//         name: 'stats',
//         builder: (context, state) => const StatsPage(),
//       ),
//       GoRoute(
//         path: privateRoutes.store,
//         name: 'store',
//         builder: (context, state) => const StoreScreen(),
//       ),
//       GoRoute(
//         path: privateRoutes.settings,
//         name: 'setting',
//         builder: (context, state) => const SettingsScreen(),
//       ),

//     ],

//     // Redirección basada en estado de autenticación
//     redirect: (context, state) async {
//       // Verificar si el usuario está autenticado
//       final bool isLoggedIn = await _authService.isLoggedIn();

//       // Rutas que requieren autenticación
//       final bool goingToAuth =
//           state.matchedLocation.contains('/auth') ||
//           state.matchedLocation == RouteNames.login;

//       // Rutas protegidas (que requieren autenticación)
//       final bool goingToProtectedRoute =
//           state.matchedLocation == RouteNames.dashboard ||
//           state.matchedLocation.contains('/dashboard') ||
//           state.matchedLocation.contains('/settings') ||
//           state.matchedLocation.contains('/store');

//       // Si el usuario NO está autenticado y trata de acceder a una ruta protegida
//       if (!isLoggedIn && goingToProtectedRoute) {
//         return RouteNames.login;
//       }

//       // Si el usuario ESTÁ autenticado y trata de acceder a rutas de auth
//       if (isLoggedIn && goingToAuth) {
//         return RouteNames.dashboard;
//       }

//       // Si el usuario ESTÁ autenticado y va a la página de inicio
//       if (isLoggedIn && state.matchedLocation == RouteNames.home) {
//         return RouteNames.dashboard;
//       }

//       // Si no hay redirección necesaria
//       return null;
//     },

//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             Text(
//               'Página no encontrada',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               state.uri.toString(),
//               style: Theme.of(context).textTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => context.go(RouteNames.home),
//               child: const Text('Ir al Inicio'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );

//   GoRouter config() {
//     return _router;
//   }
// }


class AppRouter {
  final AuthService _authService = AuthService();
  
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
        builder: (context, state) => const StatsPage(),
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
      final bool isLoggedIn = await _authService.isLoggedIn();

      print(isLoggedIn);
      
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
    if (state.matchedLocation == '/auth/reset_password' && state.extra == null) {
      return true;
    }
    return false;
  }

  GoRouter config() {
    return _router;
  }
}

