import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:go_router/go_router.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String? sessionId;
  
  const PaymentSuccessScreen({
    super.key,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1D23),
        title: Text('Pago Exitoso'),
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
                        color: Color(0xFFEDE954).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(30),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFFEDE954),
                    size: 80,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  '¡Pago completado con éxito!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Gracias por tu compra. Tu suscripción ha sido activada correctamente.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (sessionId != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'ID de transacción: $sessionId',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
                SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    // Volver a la pantalla principal
                    context.go(privateRoutes.dashboard);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFEDE954),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ir al Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
