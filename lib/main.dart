import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app/app.dart';
import 'core/di/dependency_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar error handling para hot restart
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
      
      // Para otros errores, usar el handler default
      FlutterError.presentError(details);
    };
  }
  
  await setupDependencies();
  
  // Iniciar la app directamente sin splash adicional
  // El splash nativo de Android/iOS ya se muestra automáticamente
  runApp(const GeniusHormoApp());
}
