import 'package:flutter/material.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/utils/url_launcher_utils.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/models/stripe_checkout_response.dart';
import 'package:genius_hormo/features/settings/services/plans_api_service.dart';
import 'package:genius_hormo/features/settings/services/stripe_api_service.dart';
import 'package:get_it/get_it.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final PlansApiService _plansApiService = GetIt.instance<PlansApiService>();
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  final StripeApiService _stripeApiService = GetIt.instance<StripeApiService>();
  
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  String? _purchaseError;
  List<Plan>? _plans;
  
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }
  
  Future<void> _loadPlans() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = 'No se pudo obtener el token de autenticación';
          _isLoading = false;
        });
        return;
      }
      
      final response = await _plansApiService.getPlans(authToken: token);
      
      if (!mounted) return;
      
      if (response.success && response.data != null) {
        setState(() {
          _plans = response.data!.plans;
          _isLoading = false;
        });
      } else {
        setState(() {
          // Si no hay planes, mostramos un mensaje más amigable
          if (response.message.contains('No tienes') || 
              response.error?.contains('No tienes') == true) {
            _error = 'No hay planes disponibles en este momento';
          } else {
            _error = response.error ?? 'Error desconocido';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar planes';
        _isLoading = false;
      });
      debugPrint('Error en _loadPlans: $e');
    }
  }
  
  /// Compra un plan mediante Stripe
  Future<void> _purchasePlan(Plan plan) async {
    setState(() {
      _isPurchasing = true;
      _purchaseError = null;
    });
    
    try {
      // Mostrar un diálogo de confirmación
      final shouldProceed = await _showPurchaseConfirmationDialog(plan);
      
      if (!shouldProceed) {
        setState(() {
          _isPurchasing = false;
        });
        return;
      }
      
      // Mostrar indicador de carga durante el proceso
      _showLoadingDialog();
      
      // Obtener el token de autenticación
      final token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        _dismissLoadingDialog();
        setState(() {
          _purchaseError = 'No se pudo obtener el token de autenticación';
          _isPurchasing = false;
        });
        _showErrorDialog('No se pudo obtener el token de autenticación');
        return;
      }
      
      // Crear sesión de checkout con Stripe - el backend maneja los deeplinks
      final response = await _stripeApiService.createCheckoutSession(
        authToken: token,
        planId: plan.id,
      );
      
      _dismissLoadingDialog();
      
      // Verificar que tengamos una URL de checkout válida
      if (response.success && response.data != null) {
        debugPrint('Datos de respuesta: ${response.data}');
        debugPrint('URL de checkout: ${response.data!.checkoutUrl}');
        
        // Verificar que la URL no sea nula
        if (response.data!.checkoutUrl == null) {
          setState(() {
            _purchaseError = 'No se encontró URL de checkout en la respuesta';
            _isPurchasing = false;
          });
          _showErrorDialog(_purchaseError!);
          return;
        }
        
        final checkoutUrl = response.data!.checkoutUrl!;
        debugPrint('💳 URL de checkout encontrada: $checkoutUrl');
        
        // Abrir URL de Stripe en el navegador
        final launched = await UrlLauncherUtils.launchURL(checkoutUrl);
        
        if (!launched) {
          setState(() {
            _purchaseError = 'No se pudo abrir el enlace de pago';
            _isPurchasing = false;
          });
          _showErrorDialog('No se pudo abrir el enlace de pago');
          return;
        }
        
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Se ha abierto la página de pago para el plan ${plan.title}'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _purchaseError = response.error ?? 'Error al crear la sesión de pago';
          _isPurchasing = false;
        });
        _showErrorDialog(_purchaseError!);
      }
    } catch (e) {
      _dismissLoadingDialog();
      setState(() {
        _purchaseError = e.toString();
        _isPurchasing = false;
      });
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isPurchasing = false;
      });
    }
  }
  
  /// Muestra un diálogo de confirmación para la compra
  Future<bool> _showPurchaseConfirmationDialog(Plan plan) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1C1D23),
        title: Text('Confirmar suscripción', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Deseas suscribirte al plan ${plan.plan_details?.title ?? "Plan"}?',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Precio: ${plan.plan_details?.price ?? "0.00"}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Duración: ${plan.plan_details?.days ?? 30} días',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEDE954),
              foregroundColor: Colors.black,
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  /// Muestra un diálogo de carga durante el proceso de pago
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Color(0xFF1C1D23),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFEDE954)),
              SizedBox(height: 16),
              Text(
                'Procesando pago...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Cierra el diálogo de carga
  void _dismissLoadingDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  
  /// Muestra un diálogo de error
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1C1D23),
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(errorMessage, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFEDE954)),
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        title: Text('Planes'),
        backgroundColor: Color(0xFF1C1D23),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEDE954),
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDE954),
                foregroundColor: Colors.black,
              ),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (_plans == null || _plans!.isEmpty) {
      return const Center(
        child: Text(
          'No hay planes disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Renderizar planes de la API
          ..._plans!.map((plan) {
              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEDE954), // Amarillo de la app
                  borderRadius: BorderRadius.circular(16), // Puntas redondeadas
                ),
                child: Column(
                  children: [
                    Text(
                      plan.plan_details?.title ?? 'Plan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${plan.plan_details?.price ?? "0.00"} - ${plan.plan_details?.days ?? 30} días',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _purchasePlan(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Botón negro
                        foregroundColor: Color(0xFFEDE954), // Texto amarillo
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Suscribirse',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
