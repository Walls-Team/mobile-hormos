import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/login.dart';
import 'package:genius_hormo/views/auth/register.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/buttons/outlined_button.dart';

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
        spacing: 20.0,
        children: [
          CustomElevatedButton(
            borderColor: Colors.transparent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text(
              'Log in',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          CustomOutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterScreen()),
              );
            },
            borderColor: Colors.white,
            child: Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
