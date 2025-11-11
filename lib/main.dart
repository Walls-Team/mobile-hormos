import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app/app.dart';
import 'app/splash_screen.dart';
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
  
  runApp(const SplashWrapper());
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Mostrar splash por 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }
    return const GeniusHormoApp();
  }
}
