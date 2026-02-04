import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/utils/url_launcher_utils.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/services/plans_api_service.dart';
import 'package:genius_hormo/features/settings/services/stripe_api_service.dart';

/// Controlador para manejar la lógica de negocio relacionada con los planes
class PlansController extends ChangeNotifier {
  final PlansApiService _plansApiService;
  final UserStorageService _userStorageService;
  final StripeApiService _stripeApiService;
  
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  String? _purchaseError;
  List<Plan>? _plans;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isPurchasing => _isPurchasing;
  String? get error => _error;
  String? get purchaseError => _purchaseError;
  List<Plan>? get plans => _plans;
  
  PlansController({
    required PlansApiService plansApiService,
    required UserStorageService userStorageService,
    required StripeApiService stripeApiService,
  }) : 
    _plansApiService = plansApiService,
    _userStorageService = userStorageService,
    _stripeApiService = stripeApiService {
    loadPlans();
  }
  
  /// Cargar la lista de planes disponibles
  Future<void> loadPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        _error = 'No se pudo obtener el token de autenticación';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final response = await _plansApiService.getPlans(authToken: token);
      
      if (response.success && response.data != null) {
        _plans = response.data!.plans;
        _isLoading = false;
        
        // Log básico para confirmar carga exitosa
        debugPrint('\n🔍 PLANES CARGADOS: ${_plans?.length} planes');
        
        // Verificación segura de datos
        if (_plans == null || _plans!.isEmpty) {
          debugPrint('\n⚠️ No hay planes disponibles');
        }
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      _error = 'Error al cargar planes';
      _isLoading = false;
      debugPrint('Error en loadPlans: $e');
    }
    
    notifyListeners();
  }
  
  /// Iniciar proceso de compra de un plan
  Future<bool> purchasePlan(Plan plan, Function(String) onError) async {
    _isPurchasing = true;
    _purchaseError = null;
    notifyListeners();
    
    try {
      // Obtener el token de autenticación
      final token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        _purchaseError = 'No se pudo obtener el token de autenticación';
        _isPurchasing = false;
        notifyListeners();
        onError(_purchaseError!);
        return false;
      }
      
      // Crear sesión de checkout con Stripe
      final response = await _stripeApiService.createCheckoutSession(
        authToken: token,
        planId: plan.id,
      );
      
      if (!response.success || response.data == null || response.data!.checkoutUrl == null) {
        _purchaseError = response.error ?? 'Error al crear la sesión de pago';
        _isPurchasing = false;
        notifyListeners();
        onError(_purchaseError!);
        return false;
      }
      
      final checkoutUrl = response.data!.checkoutUrl!;
      
      // Abrir URL de Stripe en el navegador
      final launched = await UrlLauncherUtils.launchURL(checkoutUrl);
      
      if (!launched) {
        _purchaseError = 'No se pudo abrir el enlace de pago';
        _isPurchasing = false;
        notifyListeners();
        onError(_purchaseError!);
        return false;
      }
      
      _isPurchasing = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _purchaseError = e.toString();
      _isPurchasing = false;
      notifyListeners();
      onError('Error: ${e.toString()}');
      return false;
    }
  }
  
  /// Manejar respuesta de error del API
  void _handleErrorResponse(ApiResponse response) {
    if (response.message.contains('No tienes') || 
        response.error?.contains('No tienes') == true) {
      _error = 'No hay planes disponibles en este momento';
    } else {
      _error = response.error ?? 'Error desconocido';
    }
    _isLoading = false;
  }
}
