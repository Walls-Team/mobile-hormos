import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
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
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();

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
      // Verificar si existe perfil completo
      final token = await _userStorageService.getJWTToken();
      if (token != null) {
        try {
          final profile = await _authService.getMyProfile(token: token);
          _hasProfile = profile.isComplete;
          debugPrint('✅ Profile check: ${_hasProfile ? "Complete" : "Incomplete"}');
          debugPrint('   Profile completion: ${profile.profileCompletionPercentage}%');
        } catch (e) {
          debugPrint('⚠️ Error checking profile: $e');
          _hasProfile = false;
        }
      }

      // TODO: Verificar si existe dispositivo conectado
      // Esto dependerá de tu implementación de dispositivos
      _hasDevice = false; // Por ahora false
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error checking user data: $e');
      setState(() {
        _isLoading = false;
        _hasProfile = false;
        _hasDevice = false;
      });
    }
  }

  // Método para refrescar el estado cuando se actualiza el perfil
  void refreshSetupStatus() {
    setState(() {
      _isLoading = true;
    });
    _checkUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determinar qué mostrar basado en el estado de configuración
    Widget currentPage;
    
    if (_currentIndex == 0) {
      // Dashboard: Mostrar setup mientras no esté completo
      currentPage = _buildSetupContent(context);
    } else if (_currentIndex == 3) {
      // Settings: Siempre permitir acceso
      currentPage = SettingsScreen();
    } else if (_currentIndex == 2) {
      // Store: Siempre permitir acceso
      currentPage = StoreScreen();
    } else {
      // Stats: Mostrar mensaje si setup no está completo
      if (!_hasProfile || !_hasDevice) {
        currentPage = _buildSetupIncompleteMessage(context);
      } else {
        currentPage = StatsScreen();
      }
    }

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
        body: currentPage,
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildSetupIncompleteMessage(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Setup Incomplete',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete your profile and connect a device to access Stats',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _currentIndex = 0; // Volver a Dashboard/Setup
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Setup'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
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
      onTap: () async {
        debugPrint('$label clicked');
        
        if (label == 'Profile') {
          debugPrint('🚀 Navegando a Settings (Profile)');
          setState(() {
            _currentIndex = 3; // Settings es el índice 3
          });
          
          // Refrescar el estado cuando vuelva de Settings
          Future.delayed(const Duration(milliseconds: 500), () {
            refreshSetupStatus();
          });
        } else if (label == 'Device') {
          debugPrint('🚀 Abriendo configuración de dispositivo');
          setState(() {
            _currentIndex = 3; // Ir a Settings donde está el botón Connect Device
          });
          
          // Mostrar SnackBar indicando dónde encontrar la opción
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📱 Tap "Connect Device" button to link your device'),
              duration: Duration(seconds: 3),
            ),
          );
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
