import 'package:flutter/material.dart';
import 'package:genius_hormo/core/di/dependency_injection.dart';
import 'package:genius_hormo/features/subscription/pages/subscription_required_screen.dart';
import 'package:genius_hormo/providers/subscription_provider.dart';

/// Guard para validar que el usuario tenga un plan activo antes de acceder a funcionalidades premium
class SubscriptionGuard {
  static final SubscriptionProvider _subscriptionProvider = getIt<SubscriptionProvider>();

  /// Verifica si el usuario puede acceder a una funcionalidad
  /// Si no tiene plan activo, navega a la pantalla de suscripción requerida
  static bool canAccess(BuildContext context, String featureName) {
    if (!_subscriptionProvider.hasActivePlan) {
      debugPrint('🚫 Acceso denegado a $featureName: No hay plan activo');
      
      // Navegar a la pantalla de suscripción requerida
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SubscriptionRequiredScreen(feature: featureName),
        ),
      );
      
      return false;
    }
    
    debugPrint('✅ Acceso permitido a $featureName');
    return true;
  }

  /// Widget wrapper que valida el acceso antes de mostrar el contenido
  static Widget requireSubscription({
    required BuildContext context,
    required Widget child,
    required String featureName,
  }) {
    if (!_subscriptionProvider.hasActivePlan) {
      return SubscriptionRequiredScreen(feature: featureName);
    }
    
    return child;
  }

  /// Verifica si el usuario tiene plan activo (sin navegación)
  static bool hasActivePlan() {
    return _subscriptionProvider.hasActivePlan;
  }
}
