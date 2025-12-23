import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/app.dart';
import 'core/auth/auth_state_provider.dart';
import 'core/di/dependency_injection.dart';
import 'services/firebase_messaging_service.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar error handling para hot restart y fallos generales
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorString = details.exception.toString();
      
      // Ignorar errores de Navigator lock durante hot restart
      if (errorString.contains('!_debugLocked')) {
        debugPrint('⚠️ Navigator lock ignorado durante hot restart');
        return;
      }
      
      // Ignorar errores de null check durante hot restart
      if (errorString.contains('Null check operator')) {
        debugPrint('⚠️ Null check error ignorado durante hot restart');
        return;
      }
      
      // Mostrar los errores en la consola
      debugPrint('🚨 ERROR: ${details.exceptionAsString()}');
      debugPrint('📄 Stack trace: ${details.stack}');
      
      // Para otros errores, usar el handler default
      FlutterError.presentError(details);
    };
  }
  
  // Inicializar Firebase primero, antes de cualquier otra cosa
  try {
    debugPrint('🔥 Inicializando Firebase...');
    await Firebase.initializeApp();
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ Error inicializando Firebase: $e');
    // Continuar la ejecución de la app aunque Firebase falle
  }
  
  // Registrar handler de notificaciones en background de manera segura
  try {
    // El handler debe estar registrado fuera de cualquier clase
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('✅ Handler de notificaciones en background registrado');
  } catch (e) {
    debugPrint('❌ Error registrando handler de notificaciones en background: $e');
    // Continuar la ejecución aunque falle el registro del handler
  }
  
  // Error handling ya está configurado arriba
  
  await setupDependencies();
  
  // Inicializar estado de autenticación ANTES de mostrar la app
  debugPrint('🔐 Inicializando autenticación...');
  final authStateProvider = AuthStateProvider();
  await authStateProvider.initializeAuthState();
  
  // Registrar el provider en GetIt para acceso global
  GetIt.instance.registerSingleton<AuthStateProvider>(authStateProvider);
  
  // Iniciar la app directamente sin splash adicional
  // El splash nativo de Android/iOS ya se muestra automáticamente
  runApp(const GeniusHormoApp());
}
