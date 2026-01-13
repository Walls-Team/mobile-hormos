import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que se muestra cuando el usuario intenta acceder a funcionalidades premium sin plan activo
class SubscriptionRequiredScreen extends StatelessWidget {
  final String? feature;
  
  const SubscriptionRequiredScreen({
    super.key,
    this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1D23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1D23),
        title: const Text('Suscripción Requerida'),
        automaticallyImplyLeading: false,  // Desactiva el botón de atrás
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF22232A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEDE954).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(30),
                  child: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFEDE954),
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Suscripción Requerida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  feature != null
                      ? 'Para acceder a $feature necesitas una suscripción activa.'
                      : 'Para acceder a esta funcionalidad necesitas una suscripción activa.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Elige un plan y desbloquea todas las funcionalidades de GeniusHormo.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    // Ir a la pantalla de planes
                    context.go(privateRoutes.settings);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDE954),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver Planes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(privateRoutes.settings),
                  child: const Text(
                    'Volver a Configuración',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
