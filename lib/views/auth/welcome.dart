import 'package:flutter/material.dart';
import 'package:genius_hormo/theme/theme.dart';
import 'package:genius_hormo/views/auth/login.dart';
import 'package:genius_hormo/views/auth/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        // height: double.infinity,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildIllustration(theme), _buildActionButtons(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(ThemeData theme) {
    return Image(image: AssetImage('assets/images/logo.png'));
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Botón de Registro (Usa ElevatedButton que hereda el tema)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
              textStyle: TextStyle(color: Colors.black),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          ),

          SizedBox(height: 20),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationForm()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white, // Color del texto
              side: const BorderSide(color: Colors.white), // Color del borde
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
