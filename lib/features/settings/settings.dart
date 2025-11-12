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
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/widgets/profile_form.dart';
import 'package:genius_hormo/features/settings/widgets/profile_skeleton_loader.dart';
import 'package:genius_hormo/features/setup/services/setup_status_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onDeviceStatusChanged;
  final VoidCallback? onAvatarChanged;
  
  const SettingsScreen({
    super.key, 
    this.onDeviceStatusChanged,
    this.onAvatarChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final SpikeApiService _spikeApiService = GetIt.instance<SpikeApiService>();
  final SetupStatusService _setupStatusService = GetIt.instance<SetupStatusService>();
  
  bool _isLoadingProfile = true;
  bool _isConnectingDevice = false;
  bool _isLoadingDeviceStatus = true;
  bool _hasDevice = false;
  String? _deviceProvider;
  String? _spikeId;
  UserProfileData? _userProfile;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadDeviceStatus();
  }

  Future<void> _loadUserProfile() async {
    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        throw Exception('No token available');
      }

      final userProfile = await _authService.getMyProfile(token: token);
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _loadDeviceStatus() async {
    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        setState(() {
          _isLoadingDeviceStatus = false;
          _hasDevice = false;
        });
        return;
      }

      final deviceResult = await _spikeApiService.getMyDevice(token: token);
      
      if (mounted) {
        setState(() {
          if (deviceResult.success && deviceResult.data != null) {
            final deviceResponse = deviceResult.data!;
            _hasDevice = deviceResponse.hasDevice && 
                        (deviceResponse.device?.isActive ?? false);
            _deviceProvider = deviceResponse.device?.provider;
            _spikeId = deviceResponse.device?.spikeIdHash;
            debugPrint('✅ Device status loaded: $_hasDevice');
            if (_hasDevice) {
              debugPrint('   Provider: $_deviceProvider');
              debugPrint('   Spike ID Hash: $_spikeId');
              debugPrint('   Device ID: ${deviceResponse.device?.id}');
              debugPrint('   Is Active: ${deviceResponse.device?.isActive}');
            }
          } else {
            _hasDevice = false;
          }
          _isLoadingDeviceStatus = false;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error loading device status: $e');
      if (mounted) {
        setState(() {
          _hasDevice = false;
          _isLoadingDeviceStatus = false;
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
                  _buildDeviceButton(),
                  // _buildFaqsButton(), // Comentado - requiere FaqsBadge widget
                  _buildLogout(),
                  SizedBox(height: 20),
                  _buildDeleteAccount(),
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
      return const ProfileSkeletonLoader();
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
      onAvatarChanged: widget.onAvatarChanged,
    );
  }

  // Widget _buildFaqsButton() {
  //   return FaqsBadge(
  //     onTap: () {
  //       SafeNavigation.goNamed(context, 'faqs');
  //     },
  //   );
  // }

  Widget _buildDeviceButton() {
    if (_isLoadingDeviceStatus) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (_hasDevice) {
      // Mostrar botón de desconectar y información del dispositivo
      return Column(
        children: [
          // Información del dispositivo conectado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.green, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Connected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (_deviceProvider != null)
                        Text(
                          'Provider: ${_deviceProvider!.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Botón de desconectar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isConnectingDevice ? null : _disconnectDevice,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              child: _isConnectingDevice
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Text(
                      'Disconnect Device',
                      style: TextStyle(color: Colors.red),
                    ),
            ),
          ),
        ],
      );
    }

    // Mostrar botón de conectar
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isConnectingDevice ? null : _connectDevice,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isConnectingDevice
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Connect Device'),
      ),
    );
  }

  Future<void> _connectDevice() async {
    try {
      setState(() => _isConnectingDevice = true);

      final token = await _userStorageService.getJWTToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      // Paso 1: Iniciar integración y obtener task_id
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Iniciando integración...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final initResult = await _spikeApiService.initiateDeviceIntegration(
        token: token,
        provider: 'whoop',
      );

      if (!initResult.success || initResult.data == null) {
        throw Exception(initResult.message ?? 'Error al iniciar integración');
      }

      final taskId = initResult.data!.taskId;
      debugPrint('✅ Task iniciado: $taskId');

      // Paso 2: Hacer polling hasta obtener integration_url
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏳ Obteniendo URL de integración...'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      final pollResult = await _spikeApiService.pollTaskUntilCompleted(
        token: token,
        taskId: taskId,
        maxAttempts: 3,
        interval: const Duration(seconds: 3),
      );

      if (!pollResult.success || pollResult.data == null) {
        throw Exception(pollResult.message ?? 'Error al obtener URL de integración');
      }

      final integrationData = pollResult.data!;
      final integrationUrl = integrationData.integrationUrl;

      debugPrint('✅ Integration URL obtenido: ${integrationUrl.substring(0, 50)}...');

      // Paso 3: Abrir URL en el navegador
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🌐 Abriendo navegador...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final uri = Uri.parse(integrationUrl);
      final canLaunch = await canLaunchUrl(uri);
      
      if (!canLaunch) {
        throw Exception('No se puede abrir la URL de integración');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('No se pudo abrir el navegador');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Navegador abierto',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Spike ID: ${integrationData.spikeId}'),
                const Text('Complete el login en el navegador'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      debugPrint('\n✅ NAVEGADOR ABIERTO EXITOSAMENTE');
      debugPrint('   Spike ID: ${integrationData.spikeId}');
      debugPrint('   Provider: ${integrationData.provider}');
      debugPrint('   Esperando callback del navegador...\n');

      // Refrescar el estado del dispositivo después de un tiempo
      Future.delayed(const Duration(seconds: 5), () {
        _setupStatusService.refreshDeviceStatus();
        _loadDeviceStatus(); // Recargar el estado local también
        widget.onDeviceStatusChanged?.call(); // Notificar al padre
        debugPrint('🔄 Estado del dispositivo actualizado');
      });

      // TODO: El callback del deeplink se manejará en otro endpoint
      
    } catch (e) {
      debugPrint('❌ Error en _connectDevice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnectingDevice = false);
      }
    }
  }

  Future<void> _disconnectDevice() async {
    try {
      setState(() => _isConnectingDevice = true);

      final token = await _userStorageService.getJWTToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      // Confirmar desconexión
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disconnect Device'),
          content: const Text(
            'Are you sure you want to disconnect your device? You will need to reconnect it to sync data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Disconnect'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() => _isConnectingDevice = false);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔌 Disconnecting device...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (_spikeId == null || _spikeId!.isEmpty) {
        throw Exception('No spike ID available');
      }

      final result = await _spikeApiService.disconnectDevice(
        token: token,
        spikeId: _spikeId!,
      );

      if (!result.success) {
        throw Exception(result.message ?? 'Error al desconectar dispositivo');
      }

      debugPrint('✅ DISPOSITIVO DESCONECTADO EXITOSAMENTE');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Device disconnected successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Actualizar estados
        setState(() {
          _hasDevice = false;
          _deviceProvider = null;
          _spikeId = null;
        });

        // Refrescar el estado global
        _setupStatusService.refreshDeviceStatus();
        
        // Notificar al padre del cambio
        widget.onDeviceStatusChanged?.call();
      }
      
    } catch (e) {
      debugPrint('❌ Error en _disconnectDevice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnectingDevice = false);
      }
    }
  }

  Widget _buildDeleteAccount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        border: Border.all(
          color: Colors.yellow,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          onPressed: _showDeleteAccountConfirmation,
          child: const Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'This action is irreversible and will result in:',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildWarningItem('• Permanent loss of all your data'),
              _buildWarningItem('• Deletion of your profile and settings'),
              _buildWarningItem('• Disconnection of linked devices'),
              _buildWarningItem('• You will not be able to recover this account'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _performDeleteAccount();
    }
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.red.shade700,
        ),
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Deleting account...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Obtener el token
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        // Cerrar loading
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication token not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Llamar al endpoint de eliminación
      final response = await _authService.deleteAccount(token: token);

      // Cerrar loading
      if (mounted) Navigator.of(context).pop();

      if (response.success) {
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Limpiar almacenamiento y desloguear
        await _authService.clearAllStorage();
        
        // Navegar al login
        Future.microtask(() {
          if (!mounted) return;
          SafeNavigation.goNamed(context, 'login');
        });
      } else {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildLogout() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _performLogout,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: Colors.red,
            width: 2.0,
          ),
        ),
        child: const Text('Log Out', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Limpiar todo el almacenamiento (token, perfil en caché, etc.)
      await _authService.clearAllStorage();
      
      // NO navegar inmediatamente - esperar a que se complete el build
      Future.microtask(() {
        if (!mounted) return;
        SafeNavigation.goNamed(context, 'login');
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
