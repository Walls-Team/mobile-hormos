import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/controllers/plans_controller.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/services/plans_api_service.dart';
import 'package:genius_hormo/features/settings/services/stripe_api_service.dart';
import 'package:genius_hormo/features/settings/widgets/plan_card.dart';
import 'package:genius_hormo/features/settings/widgets/plans_dialogs.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  late PlansController _controller;
  
  @override
  void initState() {
    super.initState();
    // Inicializar el controlador con las dependencias necesarias
    _controller = PlansController(
      plansApiService: GetIt.instance<PlansApiService>(),
      userStorageService: GetIt.instance<UserStorageService>(),
      stripeApiService: GetIt.instance<StripeApiService>(),
    );
    
    // Escuchar los cambios en el controlador
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  /// Maneja el proceso de suscripción a un plan
  Future<void> _handlePlanSubscription(Plan plan) async {
    // Mostrar diálogo de confirmación
    final shouldProceed = await PlansDialogs.showPurchaseConfirmation(context, plan);
    if (!shouldProceed) return;
    
    // Mostrar diálogo de carga
    PlansDialogs.showLoadingDialog(context);
    
    // Procesar la compra
    final success = await _controller.purchasePlan(
      plan,
      (errorMessage) {
        PlansDialogs.dismissDialog(context);
        PlansDialogs.showErrorDialog(context, errorMessage);
      },
    );
    
    // Si todo sale bien, cerrar el diálogo y mostrar mensaje de éxito
    if (success) {
      PlansDialogs.dismissDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se ha abierto la página de pago para el plan ${plan.title}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!['plans']['title']),
        backgroundColor: Color(0xFF1C1D23),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    // Estado de carga
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEDE954),
        ),
      );
    }
    
    // Estado de error
    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: ${_controller.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _controller.loadPlans(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDE954),
                foregroundColor: Colors.black,
              ),
              child: Text(AppLocalizations.of(context)!['plans']['retryButton']),
            ),
          ],
        ),
      );
    }
    
    // Sin planes disponibles
    final plans = _controller.plans;
    if (plans == null || plans.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!['plans']['noPlansAvailable'],
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    // Lista de planes
    return SingleChildScrollView(
      child: Column(
        children: [
          ...plans.map((plan) => PlanCard(
            plan: plan,
            onSubscribe: _handlePlanSubscription,
          )),
        ],
      ),
    );
  }
}
