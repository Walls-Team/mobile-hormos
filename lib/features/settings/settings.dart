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
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/faqs/faqs.dart';
import 'package:genius_hormo/features/settings/widgets/faqs_badge.dart';
import 'package:genius_hormo/features/settings/widgets/profile_form.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
  final AuthService _authService = GetIt.instance<AuthService>();
  
  bool _loading = false;
  bool _isLoadingProfile = true;
  UserProfileData? _userProfile;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      debugPrint('📱 Cargando perfil del usuario...');
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        throw Exception('No token available');
      }

      final userProfile = await _authService.getMyProfile(token: token);
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoadingProfile = false;
          debugPrint('✅ Perfil cargado: ${userProfile.username}');
        });
      }
    } catch (e) {
      debugPrint('❌ Error al cargar perfil: $e');
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _isLoadingProfile = false;
        });
      }
    }
  }

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
    if (_isLoadingProfile) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_profileError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_profileError'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserProfile,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No se pudo cargar el perfil'),
        ),
      );
    }

    return UserProfileForm(
      initialData: _userProfile!,
      onSubmit: (updatedData) {
        debugPrint('📝 Datos actualizados: ${updatedData.username}');
        // TODO: Implementar actualización de perfil en el backend
      },
    );
  }

  Widget _buildFaqsButton() {
    return FaqsBadge(
      onTap: () {
        SafeNavigation.goNamed(context, 'faqs');
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
      onPressed: _performLogout,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: Colors.red, // Color del border
          width: 2.0, // Grosor del borde
        ),
      ),
      child: Text('Log Out', style: TextStyle(color: Colors.red)),
    );
  }

  Future<void> _performLogout() async {
    try {
      debugPrint('🚪 Cerrando sesión...');
      
      // Limpiar todo el almacenamiento (token, perfil en caché, etc.)
      await _authService.clearAllStorage();
      
      debugPrint('✅ Sesión cerrada exitosamente');
      
      // NO navegar inmediatamente - esperar a que se complete el build
      Future.microtask(() {
        if (!mounted) return;
        SafeNavigation.goNamed(context, 'login');
        debugPrint('✅ Navegado al login');
      });
    } catch (e) {
      debugPrint('❌ Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
