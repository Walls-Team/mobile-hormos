import 'package:flutter/material.dart';
import 'package:genius_hormo/views/welcome.dart';
import 'package:genius_hormo/views/faqs/faqs.dart';
import 'package:genius_hormo/widgets/faqs_badge.dart';
import 'package:genius_hormo/widgets/profile_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 30.0,
          children: [
            _buildAvatar(),
            // const ProfileForm(),
            _buildFAQs(context),
            _buildConnections(context),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Cerrar Sesión'),
      content: Text('¿Estás seguro de que quieres cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // Cerrar sesión y volver al login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          child: Text('Cerrar Sesión'),
        ),
      ],
    ),
  );
}

Widget _buildFAQs(BuildContext context) {
  return Column(
    spacing: 10,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('FAQs', style: TextStyle(fontWeight: FontWeight.bold)),
      FaqsBadge(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FaqsScreen()),
          );
        },
      ),
    ],
  );
}

Widget _buildAvatar() {
  return Center(
    child: Column(
      children: [
        Text(
          'Perfil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            // color: Colors.yellow.shade700,
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: ClipOval(
            child: Image.network(
              'https://ms.geniushpro.com/avatars/5449b6e5f64161e729df4633f08162134106e76c.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, color: Colors.grey),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildConnections(context) {
  return Column(
    spacing: 10,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Connections', style: TextStyle(fontWeight: FontWeight.bold)),
      FaqsBadge(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FaqsScreen()),
          );
        },
      ),
    ],
  );
}

Widget _buildLogoutButton(context) {
  final errorColor = Theme.of(context).colorScheme.error;
  return OutlinedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    },
    style: OutlinedButton.styleFrom(
      foregroundColor: errorColor, // Color del texto
      side: BorderSide(color: errorColor), // Color del borde
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: const Text(
      'Log out',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}
