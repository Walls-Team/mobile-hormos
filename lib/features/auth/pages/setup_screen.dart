import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/dashboard/pages/dashboard.dart';
import 'package:genius_hormo/features/settings/settings.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:genius_hormo/features/stats/stats.dart';
import 'package:genius_hormo/features/store/store.dart';
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
  int _currentIndex = 0; // Para el bottom navigation

  @override
  void initState() {
    super.initState();
    _checkUserData();
  }

  Future<void> _checkUserData() async {
    try {
      // Verificar si existe perfil
      // final user = await _authService.getCurrentUser();
      // _hasProfile = user != null && user.isProfileComplete;

      // Verificar si existe dispositivo
      // final device = await _spikeService.myDevice();
      // _hasDevice = device != null;

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
    final theme = Theme.of(context);

    // Array de páginas
    final List<Widget> _pages = [
      _buildSetupContent(context), // Dashboard/Setup
      StatsScreen(),
      StoreScreen(),
      SettingsScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        // Si no estamos en Dashboard, volver a Dashboard
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false; // No salir de la app
        }
        // Si estamos en Dashboard, prevenir volver a login
        return false; // No permitir volver atrás
      },
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildSetupContent(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF252734), // Color exacto del menú
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            debugPrint('📱 Navegando a página $index');
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Color(0xFF252734),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2, size: 24),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar, size: 24),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart, size: 24),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.gear, size: 24),
              label: 'Settings',
            ),
          ],
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
        debugPrint('$label clicked');
        // Navegar a Settings (perfil)
        if (label == 'Profile') {
          debugPrint('🚀 Navegando a Settings (Profile)');
          setState(() {
            _currentIndex = 3; // Settings es el índice 3
          });
        } else if (label == 'Device') {
          debugPrint('🚀 Device setup - funcionalidad pendiente');
          // TODO: Implementar configuración de dispositivo
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
