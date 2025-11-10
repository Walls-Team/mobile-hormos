// import 'package:flutter/material.dart';
// import 'package:genius_hormo/welcome.dart';
// import 'package:genius_hormo/features/faqs/faqs.dart';
// import 'package:genius_hormo/widgets/faqs_badge.dart';
// import 'package:genius_hormo/widgets/profile_form.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           spacing: 30.0,
//           children: [
//             _buildAvatar(),
//             // const ProfileForm(),
//             _buildFAQs(context),
//             _buildConnections(context),
//             _buildLogoutButton(context),

//             ElevatedButton(onPressed: (){}, child: Text('hola'))
//           ],
//         ),
//       ),
//     );
//   }
// }

// void _showLogoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Cerrar Sesión'),
//       content: Text('¿Estás seguro de que quieres cerrar sesión?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancelar'),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           onPressed: () {
//             // Cerrar sesión y volver al login
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               '/login',
//               (route) => false,
//             );
//           },
//           child: Text('Cerrar Sesión'),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildFAQs(BuildContext context) {
//   return Column(
//     spacing: 10,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text('FAQs', style: TextStyle(fontWeight: FontWeight.bold)),
//       FaqsBadge(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const FaqsScreen()),
//           );
//         },
//       ),
//     ],
//   );
// }

// Widget _buildAvatar() {
//   return Center(
//     child: Column(
//       children: [
//         Text(
//           'Perfil',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             // color: Colors.yellow.shade700,
//           ),
//         ),
//         Container(
//           width: 100,
//           height: 100,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.grey.shade300, width: 1.5),
//           ),
//           child: ClipOval(
//             child: Image.network(
//               'https://ms.geniushpro.com/avatars/5449b6e5f64161e729df4633f08162134106e76c.jpg',
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.person, color: Colors.grey),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildConnections(context) {
//   return Column(
//     spacing: 10,
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text('Connections', style: TextStyle(fontWeight: FontWeight.bold)),
//       FaqsBadge(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const FaqsScreen()),
//           );
//         },
//       ),
//     ],
//   );
// }

// Widget _buildLogoutButton(context) {
//   final errorColor = Theme.of(context).colorScheme.error;
//   return OutlinedButton(
//     onPressed: () {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => WelcomeScreen()),
//       );
//     },
//     style: OutlinedButton.styleFrom(
//       foregroundColor: errorColor, // Color del texto
//       side: BorderSide(color: errorColor), // Color del borde
//       minimumSize: const Size(double.infinity, 50),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//     ),
//     child: const Text(
//       'Log out',
//       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//     ),
//   );
// }

import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/faqs/faqs.dart';
import 'package:genius_hormo/features/settings/widgets/faqs_badge.dart';
import 'package:genius_hormo/features/settings/widgets/profile_form.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SpikeApiService _spikeApiService = GetIt.instance<SpikeApiService>();
  final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileForm(),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 20,
                children: [
                  _buildConnectDevice(),
                  _buildFaqsButton(),
                  _buildDeleteAccount(),
                  _buildLogout(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return UserProfileForm(
      initialData: UserProfileData(
        id: '123',
        username: 'juanperez',
        email: 'juan@example.com',
        height: 175.0,
        weight: 70.0,
        language: 'es',
        gender: 'male',
        avatar:
            'https://ms.geniushpro.com/avatars/26221e75ff4065bdc2edc5c08f40329670852824.jpg',
        isComplete: false,
        profileCompletionPercentage: 60.0,
      ),
      onSubmit: (updatedData) {
        // Aquí manejas los datos actualizados
        print('Datos actualizados: $updatedData');
        // Puedes guardar en base de datos, hacer API call, etc.
      },
    );
  }

  Widget _buildFaqsButton() {
    return FaqsBadge(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaqsScreen()),
        );
      },
    );
  }

  Widget _buildConnectDevice() {
    return ElevatedButton(
      onPressed: _loading ? null : _linkDevice,
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Vincular dispositivo'),
    );
  }

  Widget _buildDeleteAccount() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.red, // Color del border
          width: 2.0, // Grosor del borde
        ),
      ),
      onPressed: () {},
      child: Text('Delete Account', style: TextStyle(color: Colors.red)),
    );
  }

  Widget _buildLogout() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.red, // Color del border
          width: 2.0, // Grosor del borde
        ),
      ),
      child: Text('Log Out', style: TextStyle(color: Colors.red)),
    );
  }

  Future<void> _linkDevice() async {
    setState(() => _loading = true);
    try {
      final token = await _userStorageService.getJWTToken();

      final providerIntegrationInit = await _spikeApiService
          .requestWhoopIntegration(userId: '1', token: token!);

      if (providerIntegrationInit.path.isNotEmpty) {
        final uri = Uri.parse(providerIntegrationInit.path);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw Exception('No se pudo abrir la URL de vinculación');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario de vinculación abierto')),
          );
        }
      }

      print(providerIntegrationInit.path);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
