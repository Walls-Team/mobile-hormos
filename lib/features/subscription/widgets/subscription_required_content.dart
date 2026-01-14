import 'package:flutter/material.dart';
import 'package:genius_hormo/features/settings/pages/plans_screen.dart';

/// Widget de contenido para mostrar cuando se requiere suscripción
/// Este widget NO incluye Scaffold, para ser usado dentro de otras pantallas
class SubscriptionRequiredContent extends StatelessWidget {
  final String? feature;
  
  const SubscriptionRequiredContent({
    super.key,
    this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
                // Navegar a la pantalla de planes
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlansScreen(),
                  ),
                );
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
          ],
        ),
      ),
    );
  }
}
