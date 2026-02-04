import 'package:flutter/material.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

/// Widget que muestra una tarjeta con la información de un plan
class PlanCard extends StatelessWidget {
  final Plan plan;
  final Function(Plan) onSubscribe;
  
  const PlanCard({
    Key? key,
    required this.plan,
    required this.onSubscribe,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFEDE954),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del plan
          Text(
            plan.plan_details?.title ?? 'Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          // Descripción si existe
          if (plan.plan_details?.description != null && plan.plan_details!.description.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              plan.plan_details!.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
          
          // Precio y duración
          SizedBox(height: 8),
          Text(
            '\$${plan.plan_details?.price ?? "0.00"} - ${plan.plan_details?.days ?? 30} días',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Botón de suscripción
          Center(
            child: ElevatedButton(
              onPressed: () => onSubscribe(plan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Color(0xFFEDE954),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!['plans']['subscribe'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
