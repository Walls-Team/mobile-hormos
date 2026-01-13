import 'package:flutter/foundation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/services/plans_api_service.dart';

/// Provider para gestionar el estado global de la suscripción del usuario
class SubscriptionProvider extends ChangeNotifier {
  final PlansApiService _plansApiService;
  final UserStorageService _userStorageService;

  Plan? _currentPlan;
  bool _isLoading = false;
  String? _error;
  bool _hasCheckedPlan = false;

  SubscriptionProvider({
    required PlansApiService plansApiService,
    required UserStorageService userStorageService,
  })  : _plansApiService = plansApiService,
        _userStorageService = userStorageService;

  // Getters
  Plan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCheckedPlan => _hasCheckedPlan;
  
  /// Verifica si el usuario tiene un plan activo
  bool get hasActivePlan => _currentPlan != null;
  
  /// Verifica si el usuario puede acceder a las funcionalidades premium
  bool get canAccessPremiumFeatures => hasActivePlan;

  /// Consulta el plan actual del usuario
  Future<void> fetchCurrentPlan() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        debugPrint('🔴 SubscriptionProvider: No hay token disponible');
        _error = 'No hay sesión activa';
        _isLoading = false;
        _hasCheckedPlan = true;
        notifyListeners();
        return;
      }

      debugPrint('🔍 SubscriptionProvider: Consultando plan actual...');
      final response = await _plansApiService.getCurrentPlan(authToken: token);

      if (response.success && response.data != null) {
        _currentPlan = response.data;
        _error = null;
        debugPrint('✅ SubscriptionProvider: Plan obtenido - ${_currentPlan!.plan_details?.title ?? "Plan Desconocido"}');
      } else {
        _currentPlan = null;
        _error = response.message;
        debugPrint('⚠️ SubscriptionProvider: ${response.message}');
      }
    } catch (e) {
      _currentPlan = null;
      _error = 'Error al obtener el plan actual';
      debugPrint('❌ SubscriptionProvider: Error - $e');
    } finally {
      _isLoading = false;
      _hasCheckedPlan = true;
      notifyListeners();
    }
  }

  /// Actualiza el plan después de una compra exitosa
  Future<void> refreshAfterPurchase() async {
    debugPrint('🔄 SubscriptionProvider: Actualizando plan después de compra...');
    await fetchCurrentPlan();
  }

  /// Limpia el plan actual (útil para logout)
  void clearPlan() {
    _currentPlan = null;
    _error = null;
    _hasCheckedPlan = false;
    notifyListeners();
    debugPrint('🧹 SubscriptionProvider: Plan limpiado');
  }

  /// Verifica si el usuario puede acceder a una funcionalidad específica
  bool canAccess(String feature) {
    if (!hasActivePlan) {
      debugPrint('🚫 Acceso denegado a $feature: No hay plan activo');
      return false;
    }
    
    debugPrint('✅ Acceso permitido a $feature');
    return true;
  }
}
