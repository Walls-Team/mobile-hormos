import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:go_router/go_router.dart';

class PaymentCancelledScreen extends StatelessWidget {
  final String? sessionId;
  
  const PaymentCancelledScreen({
    super.key,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1D23),
        title: Text('Pago Cancelado'),
        automaticallyImplyLeading: false,
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
                    color: Color(0xFF22232A),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(30),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.redAccent,
                    size: 80,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Pago cancelado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'El proceso de pago ha sido cancelado. No se ha realizado ningún cargo a tu cuenta.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Volver a la pantalla de planes
                        context.go(privateRoutes.plans);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEDE954),
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Volver a planes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        // Volver al dashboard
                        context.go(privateRoutes.dashboard);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white24),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Ir al Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
