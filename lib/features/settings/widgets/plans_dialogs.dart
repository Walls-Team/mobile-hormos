import 'package:flutter/material.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

/// Clase utilitaria para manejar los diálogos de la pantalla de planes
class PlansDialogs {
  /// Muestra un diálogo de confirmación para la compra de un plan
  static Future<bool> showPurchaseConfirmation(BuildContext context, Plan plan) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1C1D23),
        title: Text(
          AppLocalizations.of(context)!['plans']['confirmSubscription'],
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!['common']['subscribe']} ${plan.plan_details?.title ?? "Plan"}?',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!['common']['price']}: \$${plan.plan_details?.price ?? "0.00"}',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              '${AppLocalizations.of(context)!['common']['duration']}: ${plan.plan_details?.days ?? 30} ${AppLocalizations.of(context)!['common']['days']}',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!['plans']['cancel'],
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEDE954),
              foregroundColor: Colors.black,
            ),
            child: Text(AppLocalizations.of(context)!['plans']['confirm']),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Muestra un diálogo de carga durante el proceso de pago
  static void showLoadingDialog(BuildContext context) {
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
                AppLocalizations.of(context)!['plans']['processingPayment'],
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo de error
  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1C1D23),
        title: Text(
          AppLocalizations.of(context)!['plans']['error'],
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          errorMessage, 
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Color(0xFFEDE954)),
            child: Text(AppLocalizations.of(context)!['plans']['accept']),
          ),
        ],
      ),
    );
  }

  /// Cierra el diálogo actual si está abierto
  static void dismissDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
