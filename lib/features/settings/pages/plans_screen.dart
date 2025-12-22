import 'package:flutter/material.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Array de planes
    final plans = [
      {'name': 'Plan Básico', 'price': '\$9.99', 'days': '30 días'},
      {'name': 'Plan Pro', 'price': '\$24.99', 'days': '90 días'},
      {'name': 'Plan Premium', 'price': '\$44.99', 'days': '180 días'},
      {'name': 'Plan Anual', 'price': '\$79.99', 'days': '365 días'},
    ];

    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        title: Text('Planes'),
        backgroundColor: Color(0xFF1C1D23),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Renderizar array con .map()
            ...plans.map((plan) {
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
                      plan['name'] as String,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${plan['price']} - ${plan['days']}',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
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
      ),
    );
  }
}
