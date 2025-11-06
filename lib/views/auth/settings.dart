import 'package:flutter/material.dart';
import 'package:genius_hormo/widgets/profile_form.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(color: Colors.yellow),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.yellow,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.yellow.shade700,
              ),
            ),
            const SizedBox(height: 20),
            const ProfileForm(),
          ],
        ),
      ),
    );
  }
}