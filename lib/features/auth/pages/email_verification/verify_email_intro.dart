import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/verify_email.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class VerifyEmailIntroScreen extends StatelessWidget {
  final String email;

  const VerifyEmailIntroScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            
            // Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.mail_outline,
                          size: 60,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      
                      SizedBox(height: 30),
                      
                      // Title
                      Text(
                        AppLocalizations.of(context)!['auth']['emailVerification']['verifyIntroTitle'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Description
                      Text(
                        AppLocalizations.of(context)!['auth']['emailVerification']['verifyIntroMessage'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Email
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Additional info
                      Text(
                        AppLocalizations.of(context)!['auth']['emailVerification']['verifyIntroHelper'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navegar a la pantalla de código de verificación
                    // TODO: Convertir a ruta con extra en GoRouter
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationCodeScreen(email: email),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!['auth']['emailVerification']['continueButton'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
