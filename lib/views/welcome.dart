import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [_buildIllustration(), _buildActionButtons(context)],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Image(
      image: AssetImage('assets/images/logo.png'),
      height: 150,
      fit: BoxFit.contain,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Log in'),
          ),

          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }
}
