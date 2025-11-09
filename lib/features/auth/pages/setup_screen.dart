import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final SpikeApiService _spikeService = GetIt.instance<SpikeApiService>();
  final AuthService _authService = GetIt.instance<AuthService>();

  bool _hasProfile = false;
  bool _hasDevice = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    try {
      // Verificar si existe perfil
      final user = await _authService.getCurrentUser();
      _hasProfile = user != null && user.isProfileComplete;

      // Verificar si existe dispositivo
      final device = await _spikeService.myDevice();
      _hasDevice = device != null;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoSection(context),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    // Lista de elementos clickables
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildClickableItem(
                            isConnected: _hasDevice,
                            label: 'Device',
                            status: _hasDevice ? 'Connected' : 'Not connected',
                            statusColor: _hasDevice ? Colors.green : Colors.red,
                            icon: Icon(
                              CupertinoIcons.device_phone_portrait,
                              size: 30,
                              color: _hasDevice ? Colors.green : Colors.red,
                            ),
                            showCheck: _hasDevice,
                          ),
                          const SizedBox(height: 16),
                          _buildClickableItem(
                            isConnected: _hasProfile,
                            label: 'Profile',
                            status: _hasProfile ? 'Connected' : 'Not connected',
                            statusColor: _hasProfile
                                ? Colors.green
                                : Colors.red,
                            icon: Icon(
                              CupertinoIcons.person,
                              size: 30,
                              color: _hasProfile ? Colors.green : Colors.red,
                            ),
                            showCheck: _hasProfile,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [_buildLoginIcon(), _buildWelcomeMessage(context)],
      ),
    );
  }

  Widget _buildLoginIcon() {
    return Center(
      child: Image.asset(
        'assets/images/logo_2.png',
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: Column(
        children: [
          Text(
            'Configuration Setup',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete all steps to access the dashboard',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableItem({
    required bool isConnected,
    required String label,
    required String status,
    required Color statusColor,
    Widget? icon,
    bool showCheck = false,
  }) {
    return InkWell(
      onTap: () {
        print('$label clicked');
        // Aquí puedes agregar navegación según el item
        if (label == 'Profile' && !isConnected) {
          // Navegar a pantalla de perfil
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
        } else if (label == 'Device' && !isConnected) {
          // Navegar a pantalla de dispositivos
          // Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceScreen()));
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Icono con color según estado
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon,
              ),
            const SizedBox(width: 16),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      color: statusColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Check verde si está conectado
            if (showCheck)
              const Icon(Icons.check_circle, size: 24, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
