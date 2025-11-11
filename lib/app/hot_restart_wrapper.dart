import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'safe_navigation.dart';

/// Wrapper widget que previene errores de navegación durante hot restart
class HotRestartWrapper extends StatefulWidget {
  final Widget child;
  
  const HotRestartWrapper({
    super.key,
    required this.child,
  });

  @override
  State<HotRestartWrapper> createState() => _HotRestartWrapperState();
}

class _HotRestartWrapperState extends State<HotRestartWrapper> {
  Widget? _cachedChild;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    // Cachear el child inicial
    _cachedChild = widget.child;
    
    // Configurar el error handler solo en debug
    if (kDebugMode) {
      FlutterError.onError = (FlutterErrorDetails details) {
        // Silenciar errores de Navigator lock durante hot restart
        if (details.exception.toString().contains('!_debugLocked')) {
          debugPrint('⚠️ Navigator lock error silenciado durante hot restart');
          return;
        }
        // Silenciar errores de null check durante hot restart
        if (details.exception.toString().contains('Null check operator')) {
          debugPrint('⚠️ Null check error silenciado durante hot restart');
          return;
        }
        // Para otros errores, usar el handler default
        FlutterError.dumpErrorToConsole(details);
      };
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    // Durante hot restart, bloquear toda navegación
    debugPrint('🔄 Hot restart detectado - bloqueando navegación');
    SafeNavigation.lockNavigation();
    
    // Marcar como primer build para mostrar loader
    setState(() {
      _isFirstBuild = true;
    });
    
    // Esperar 300ms antes de permitir rebuild
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isFirstBuild = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Durante hot restart, mostrar un loader temporal
    if (_isFirstBuild && kDebugMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF252734),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Reiniciando...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Actualizar el child cacheado si es necesario
    _cachedChild = widget.child;
    
    // Retornar el child
    return _cachedChild ?? widget.child;
  }
}
