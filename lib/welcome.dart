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
