import 'package:flutter/material.dart';
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:genius_hormo/core/auth/auth_state_provider.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/faqs/faqs.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/pages/plans_screen.dart';
import 'package:genius_hormo/features/settings/widgets/faqs_badge.dart';
import 'package:genius_hormo/features/settings/widgets/profile_form.dart';
import 'package:genius_hormo/features/settings/widgets/profile_skeleton_loader.dart';
import 'package:genius_hormo/features/setup/services/setup_status_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:genius_hormo/providers/subscription_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/features/settings/widgets/biometric_settings.dart';

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
  // Para navegar a la tab de Store
  int _currentIndex = 0;
  
  final UserStorageService _userStorageService =
      GetIt.instance<UserStorageService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final SpikeApiService _spikeApiService = GetIt.instance<SpikeApiService>();
  final SetupStatusService _setupStatusService = GetIt.instance<SetupStatusService>();
  final SubscriptionProvider _subscriptionProvider = GetIt.instance<SubscriptionProvider>();
  
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
    _loadCurrentPlan();
  }
  
  Future<void> _loadCurrentPlan() async {
    // El plan ya debería estar cargado en el provider desde App.dart
    // pero hacemos un refresh para asegurarnos de tener datos actualizados
    // Este plan ahora se muestra en el formulario de perfil, por encima de la sección de idioma
    
    // Solo cargamos si no se ha verificado antes o si han pasado más de 2 minutos
    // para evitar hacer demasiadas llamadas innecesarias a la API
    if (!_subscriptionProvider.hasCheckedPlan) {
      debugPrint('🔄 SettingsScreen: Cargando plan por primera vez');
      await _subscriptionProvider.fetchCurrentPlan();
    } else {
      debugPrint('✅ SettingsScreen: Plan ya verificado anteriormente');
      
      // Programamos una actualización asíncrona del plan para mantenerlo actualizado
      // pero sin bloquear la interfaz de usuario
      Future.microtask(() => _subscriptionProvider.fetchCurrentPlan());
    }
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
                  const SizedBox(height: 16),
                  
                  // Configuración de Face ID / Touch ID
                  BiometricSettings(
                    userEmail: _userProfile?.email,
                  ),
                  
                  _buildFaqsButton(),
                  _buildLogout(),
                  SizedBox(height: 0),
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
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_outlined, 
                size: 64, 
                color: Colors.orange.withOpacity(0.7),
              ),
              SizedBox(height: 24),
              Text(
                'Sin conexión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No se pudo cargar tu perfil. Verifica tu conexión a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
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
          child: Text(AppLocalizations.of(context)!['errors']['profileLoadError']),
        ),
      );
    }

    return UserProfileForm(
      initialData: _userProfile!,
      onSubmit: (updatedData) {
      debugPrint('📝 Data updated: ${updatedData.username}');
        debugPrint('✅ Profile complete: ${updatedData.isComplete}');
        
        // Update profile status immediately
        setState(() {
          _userProfile = updatedData;
        });
        
        debugPrint('🔄 Status updated - Connect Device button should update');
      },
      onAvatarChanged: widget.onAvatarChanged,
    );
  }

  // La tarjeta del plan ahora se muestra en el formulario de perfil,
  // por encima de la sección de idioma

  Widget _buildFaqsButton() {
    return FaqsBadge(
      onTap: () {
        // Navegar con Navigator ROOT para bypass completamente GoRouter
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => const FaqsScreen(),
          ),
        );
      },
    );
  }

  Widget _buildDeviceButton() {
    // Si no hay plan activo, mostrar mensaje de bloqueo
    if (!_subscriptionProvider.hasActivePlan) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suscripción Requerida',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Necesitas un plan activo para conectar dispositivos.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey[800],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Conectar Dispositivo',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    
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
      // Show disconnect button and device information
      return Column(
        children: [
          // Connected device information
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
                        AppLocalizations.of(context)!['settings']['deviceConnected'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      if (_deviceProvider != null)
                        Text(
                          '${AppLocalizations.of(context)!['settings']['provider']}: ${_deviceProvider!.toUpperCase()}',
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
          // Disconnect button
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
                  : Text(
                      AppLocalizations.of(context)!['settings']['deviceDisconnect'],
                      style: const TextStyle(color: Colors.red),
                    ),
            ),
          ),
        ],
      );
    }

    // Check if profile is complete
    final bool isProfileComplete = _userProfile?.isComplete ?? false;

    // Show connect button with validation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Information banner if profile is not complete
        if (!isProfileComplete)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!['settings']['profileForm']['completeProfileTitle'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!['settings']['profileForm']['completeProfileMessage'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        
        // Connect button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isConnectingDevice || !isProfileComplete) 
                ? null 
                : _connectDevice,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isProfileComplete 
                  ? null // Usa el color del theme
                  : Colors.grey[800], // Color deshabilitado
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isProfileComplete)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      Text(
                        AppLocalizations.of(context)!['dashboard']['connectDevice'],
                        style: TextStyle(
                          color: isProfileComplete 
                              ? Colors.black 
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _connectDevice() async {
    try {
      setState(() => _isConnectingDevice = true);

      final token = await _userStorageService.getJWTToken();
      if (token == null) {
        throw Exception(AppLocalizations.of(context)!['settings']['deviceConnection']['noActiveSession']);
      }

      // Step 1: Start integration and get task_id
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚀 ${AppLocalizations.of(context)!['settings']['deviceConnection']['startingIntegration']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final initResult = await _spikeApiService.initiateDeviceIntegration(
        token: token,
        provider: 'whoop',
      );

      if (!initResult.success || initResult.data == null) {
        final localizations = AppLocalizations.of(context)!;
        throw Exception(initResult.message ?? localizations['settings']['deviceConnection']['errorStartingIntegration']);
      }

      final taskId = initResult.data!.taskId;
      debugPrint('✅ Task started: $taskId');

      // Paso 2: Hacer polling hasta obtener integration_url
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏳ ${AppLocalizations.of(context)!['settings']['deviceConnection']['gettingUrl']}'),
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
        throw Exception(pollResult.message ?? AppLocalizations.of(context)!['settings']['deviceConnection']['errorGettingUrl']);
      }

      final integrationData = pollResult.data!;
      final integrationUrl = integrationData.integrationUrl;

      debugPrint('✅ Integration URL obtained: ${integrationUrl.substring(0, 50)}...');

      // Paso 3: Abrir URL en el navegador
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🌐 ${AppLocalizations.of(context)!['settings']['deviceConnection']['openingBrowser']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final uri = Uri.parse(integrationUrl);
      final canLaunch = await canLaunchUrl(uri);
      
      if (!canLaunch) {
        throw Exception(AppLocalizations.of(context)!['settings']['deviceConnection']['cannotOpenUrl']);
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(AppLocalizations.of(context)!['settings']['deviceConnection']['couldNotOpenBrowser']);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ ${AppLocalizations.of(context)!['settings']['deviceConnection']['browserOpened']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Spike ID: ${integrationData.spikeId}'),
                Text(AppLocalizations.of(context)!['settings']['deviceConnection']['completeBrowserLogin']),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      debugPrint('\n✅ BROWSER OPENED SUCCESSFULLY');
      debugPrint('   Spike ID: ${integrationData.spikeId}');
      debugPrint('   Provider: ${integrationData.provider}');
      debugPrint('   Waiting for browser callback...\n');

      // Refresh device status after some time
      Future.delayed(const Duration(seconds: 5), () {
        _setupStatusService.refreshDeviceStatus();
        _loadDeviceStatus(); // Reload local status as well
        widget.onDeviceStatusChanged?.call(); // Notify parent of change
        debugPrint('Device status updated');
      });

      // TODO: The deeplink callback will be handled in another endpoint
      
    } catch (e) {
      debugPrint('Error in _connectDevice: $e');
      debugPrint('❌ Error in _connectDevice: $e');
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
        throw Exception(AppLocalizations.of(context)!['settings']['deviceConnection']['noActiveSession']);
      }

      // Confirmar desconexión
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!['settings']['deviceConnection']['disconnectConfirmTitle']),
          content: Text(
            AppLocalizations.of(context)!['settings']['deviceConnection']['disconnectConfirmMessage'],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!['common']['cancel']),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!['settings']['deviceConnection']['disconnect']),
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
          SnackBar(
            content: Text('🔌 ${AppLocalizations.of(context)!['settings']['deviceConnection']['disconnecting']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (_spikeId == null || _spikeId!.isEmpty) {
        throw Exception(AppLocalizations.of(context)!['settings']['deviceConnection']['noSpikeId']);
      }

      final result = await _spikeApiService.disconnectDevice(
        token: token,
        spikeId: _spikeId!,
      );

      if (!result.success) {
        throw Exception(result.message ?? AppLocalizations.of(context)!['settings']['deviceConnection']['errorDisconnecting']);
      }

      debugPrint('✅ DISCONNECT REQUEST SUCCESSFUL');
      
      // Añadir un pequeño retraso para permitir que el backend procese la desconexión
      await Future.delayed(Duration(seconds: 1));
      
      // Validar que el dispositivo realmente esté desconectado
      debugPrint('🔍 Verificando estado de desconexión del dispositivo...');
      
      // Intentar verificar hasta 3 veces
      bool disconnectionConfirmed = false;
      String? verificationError;
      int maxRetries = 3;
      
      for (int i = 0; i < maxRetries; i++) {
        try {
          // Obtener el estado actual del dispositivo
          final userDeviceResult = await _spikeApiService.getUserDevice(
            token: token,
          );
          
          if (!userDeviceResult.success) {
            // Si no hay éxito pero es porque no hay dispositivo, es correcto
            final errorMessage = userDeviceResult.message.toLowerCase();
            
            // Verificar diferentes variantes de mensajes de "no hay dispositivos"
            if (errorMessage.contains('no device') || 
                errorMessage.contains('no hay dispositivo') ||
                errorMessage.contains('do not have any device') ||
                errorMessage.contains('you do not have any devices')) {
              disconnectionConfirmed = true;
              debugPrint('✅ Desconexión confirmada: No hay dispositivo conectado');
              debugPrint('✅ Mensaje de API: ${userDeviceResult.message}');
              break;
            } else {
              // Otro tipo de error
              throw Exception('Error verificando estado del dispositivo: ${userDeviceResult.message}');
            }
          }
          
          // Si hay un dispositivo devuelto pero es null o tiene ID distinto, también está desconectado
          // Primero verificar que data no sea null y que sea un Map
          if (userDeviceResult.data == null) {
            disconnectionConfirmed = true;
            debugPrint('✅ Desconexión confirmada: No hay datos de dispositivo (null)');
            break;
          }
          
          // Verificar que data contenga spike_id
          final spikeId = userDeviceResult.data?['spike_id'];
          if (spikeId == null || spikeId != _spikeId) {
            disconnectionConfirmed = true;
            debugPrint('✅ Desconexión confirmada: ID diferente o no encontrado');
            break;
          }
          
          // Si aún detectamos el mismo dispositivo, esperar y reintentar
          debugPrint('⚠️ Aún se detecta el mismo dispositivo. Reintentando... ${i+1}/$maxRetries');
          await Future.delayed(Duration(seconds: 2)); // Esperar antes de reintentar
          
        } catch (e) {
          verificationError = e.toString();
          debugPrint('❌ Error verificando desconexión: $e');
          await Future.delayed(Duration(seconds: 2)); // Esperar antes de reintentar
        }
      }
      
      if (!disconnectionConfirmed) {
        throw Exception(verificationError ?? AppLocalizations.of(context)!["device"]["connection"]["disconnectMaxRetries"]);
      }

      debugPrint('✅ DEVICE DISCONNECTED AND VERIFIED SUCCESSFULLY');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${AppLocalizations.of(context)!["settings"]["deviceConnection"]["disconnectSuccess"]}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Update statuses
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
      debugPrint('❌ Error in _disconnectDevice: $e');
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
          child: Text(
            AppLocalizations.of(context)!['settings']['deleteAccount'],
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
              Text(AppLocalizations.of(context)!['settings']['deleteAccountModal']['title']),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!['settings']['deleteAccountModal']['questionTitle'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!['settings']['deleteAccountModal']['message'],
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 8),
              _buildWarningItem(AppLocalizations.of(context)!['settings']['deleteAccountModal']['warning1']),
              _buildWarningItem(AppLocalizations.of(context)!['settings']['deleteAccountModal']['warning2']),
              _buildWarningItem(AppLocalizations.of(context)!['settings']['deleteAccountModal']['warning3']),
              _buildWarningItem(AppLocalizations.of(context)!['settings']['deleteAccountModal']['warning4']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                AppLocalizations.of(context)!['common']['cancel'],
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!['settings']['deleteAccountModal']['confirm']),
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
                  Text(AppLocalizations.of(context)!['settings']['deleteAccountModal']['deleting']),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Get the token
      final token = await _userStorageService.getJWTToken();
      
      if (token == null) {
        // Close loading
        if (mounted) Navigator.of(context).pop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!['settings']['profileForm']['noTokenAvailable']),
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

        // Clear storage and log out
        await _authService.clearAllStorage();
        
        // Navigate to login
        Future.microtask(() {
          if (!mounted) return;
          SafeNavigation.goNamed(context, 'login');
        });
      } else {
        // Show error
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
        child: Text(AppLocalizations.of(context)!['settings']['logOut'], style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Clear all storage (token, cached profile, etc.)
      await _authService.clearAllStorage();
      
      // Mark as unauthenticated in AuthStateProvider
      final authStateProvider = GetIt.instance<AuthStateProvider>();
      authStateProvider.setUnauthenticated();
      debugPrint('✅ AuthStateProvider updated - User logged out');
      
      // DON'T navigate immediately - wait for build to complete
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
