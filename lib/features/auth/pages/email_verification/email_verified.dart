import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:go_router/go_router.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class EmailVerifiedScreen extends StatelessWidget {
  final String email;

  const EmailVerifiedScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Card en el centro
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Card(
                  margin: EdgeInsets.all(30),
                  child: Center(
                    child: Column(
                      spacing: 10.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Título
                        _buildIcon(context),
                        Text(
                          AppLocalizations.of(context)!['auth']['emailVerification']['verifiedTitle'],
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        // Mensaje
                        Text(
                          AppLocalizations.of(context)!['auth']['emailVerification']['verifiedMessage'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botón en la parte inferior
          Padding(
            padding: EdgeInsets.only(bottom: 60, left: 24, right: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.goNamed('login');
                },
                child: Text(AppLocalizations.of(context)!['auth']['emailVerification']['continueButton']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Espacio entre el borde y el icono interno
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12.0), // Tamaño del círculo interno
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          Icons.check, // o Icons.verified, Icons.done, etc.
          color: Theme.of(context).colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }
}
