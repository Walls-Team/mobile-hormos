import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildResponsiveTopSpacing(), // Espacio superior responsive
            _buildIllustration(),
            const SizedBox(height: 40), // Espacio reducido entre logo y botones
            _buildActionButtons(context),
            const SizedBox(height: 40), // Espacio inferior
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveTopSpacing() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Espacio superior responsive: 15% del alto de la pantalla
        final screenHeight = MediaQuery.of(context).size.height;
        final topSpacing = screenHeight * 0.15;
        
        return SizedBox(height: topSpacing);
      },
    );
  }

  Widget _buildIllustration() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Logo responsive ajustado para iPhone 16:
        // iPhone 16 (852px): 35% = ~298px (más grande)
        // Dispositivos pequeños (<700px): 40%
        // Dispositivos grandes (>900px): 32%
        final screenHeight = MediaQuery.of(context).size.height;
        double logoHeight;
        
        if (screenHeight < 700) {
          logoHeight = screenHeight * 0.40; // Dispositivos pequeños
        } else if (screenHeight > 900) {
          logoHeight = screenHeight * 0.32; // Tablets/iPad
        } else {
          logoHeight = screenHeight * 0.35; // iPhone 16 y similares
        }
        
        return Image(
          image: AssetImage('assets/images/logo.png'),
          height: logoHeight,
          fit: BoxFit.contain,
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        spacing: 20.0,
        children: [
          ElevatedButton(
            onPressed: () {
              context.goNamed('login');
            },
            child: Text('Log in'),
          ),

          OutlinedButton(
            onPressed: () {
              context.goNamed('register');
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
