import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/core/guards/subscription_guard.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/dashboard/pages/dashboard.dart';
import 'package:genius_hormo/features/daily_questions/services/daily_questions_dialog_service.dart';
import 'package:genius_hormo/features/settings/settings.dart';
import 'package:genius_hormo/features/subscription/pages/subscription_required_screen.dart';
import 'package:genius_hormo/features/subscription/widgets/subscription_required_content.dart';
import 'package:genius_hormo/providers/subscription_provider.dart';
import 'package:genius_hormo/services/whoop_promo_service.dart';
import 'package:genius_hormo/services/firebase_messaging_service.dart';
import 'package:genius_hormo/services/local_notifications_service.dart';
import 'package:genius_hormo/widgets/whoop_promo_modal.dart';
import 'package:genius_hormo/features/setup/services/setup_status_service.dart';
import 'package:genius_hormo/features/stats/stats.dart';
import 'package:genius_hormo/features/store/store.dart';
import 'package:genius_hormo/features/notifications/notifications_screen.dart';
import 'package:genius_hormo/widgets/app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/features/chat/pages/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final SetupStatusService _setupStatusService = GetIt.instance<SetupStatusService>();
  final DailyQuestionsDialogService _dailyQuestionsService = DailyQuestionsDialogService();
  final WhoopPromoService _whoopPromoService = GetIt.instance<WhoopPromoService>();
  final FirebaseMessagingService _firebaseMessagingService = GetIt.instance<FirebaseMessagingService>();
  final LocalNotificationsService _localNotificationsService = GetIt.instance<LocalNotificationsService>();
  final SubscriptionProvider _subscriptionProvider = GetIt.instance<SubscriptionProvider>();

  UserProfileData? _userProfile;
  bool _isLoading = true;
  bool _isSetupComplete = false;

  @override
  void initState() {
    super.initState();
    // Inicializar datos después del primer frame para evitar problemas en hot restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    debugPrint('📱 Verificando estado del setup...');

    try {
      // Primero cargar el plan actual del usuario
      await _subscriptionProvider.fetchCurrentPlan();
      
      final setupStatus = await _setupStatusService.checkSetupStatus();
      
      if (mounted) {
        setState(() {
          _isSetupComplete = setupStatus.isComplete;
          _userProfile = setupStatus.profile;
          _isLoading = false;
        });
        
        // Mostrar cuestionario diario si el perfil está completo Y dispositivo conectado
        if (_userProfile != null) {
          // Esperar un poco más para que la UI esté lista
          Future.delayed(const Duration(seconds: 2), () async {
            if (mounted) {
              debugPrint('📋 Verificando cuestionario diario...');
              final hasDevice = _setupStatusService.currentStatus.hasDevice;
              final hasProfile = _userProfile?.isComplete ?? false;
              
              _dailyQuestionsService.checkAndShowDailyQuestions(
                context,
                hasProfile: hasProfile,
                hasDevice: hasDevice,
              );
              
              // Mostrar modal de WHOOP después del cuestionario (si corresponde)
              // Solo si NO tiene dispositivo conectado
              Future.delayed(const Duration(milliseconds: 500), () async {
                if (mounted) {
                  final hasDevice = _setupStatusService.currentStatus.hasDevice;
                  final shouldShow = await _whoopPromoService.shouldShowPromo(
                    hasDevice: hasDevice,
                  );
                  if (shouldShow && mounted) {
                    await WhoopPromoModal.show(context);
                    await _whoopPromoService.markAsShown();
                  }
                }
              });
            }
          });
        }
      }

      debugPrint('✅ Setup verificado - Completo: $_isSetupComplete');
      
      // Inicializar Firebase Messaging después de la autenticación
      _initializeFirebaseMessaging();
    } catch (e) {
      debugPrint('❌ Error al verificar setup: $e');
      if (mounted) {
        setState(() {
          _isSetupComplete = false;
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _initializeFirebaseMessaging() async {
    try {
      debugPrint('🔔 Inicializando sistema de notificaciones...');
      
      // 1. Inicializar servicio de notificaciones locales
      await _localNotificationsService.initialize();
      debugPrint('✅ Servicio de notificaciones locales inicializado');
      
      // 2. Conectar Firebase Messaging con servicio local
      _firebaseMessagingService.setLocalNotificationsService(_localNotificationsService);
      
      // 3. Inicializar Firebase Messaging
      await _firebaseMessagingService.initialize();
      
      // 4. Suscribirse a topics generales
      await _firebaseMessagingService.subscribeToTopic('all_users');
      
      // 5. Suscribirse a topics específicos según el estado del usuario
      if (_isSetupComplete) {
        await _firebaseMessagingService.subscribeToTopic('complete_profiles');
      }
      
      debugPrint('✅ Sistema de notificaciones configurado correctamente');
    } catch (e) {
      debugPrint('⚠️ Error configurando notificaciones: $e');
      // No bloquear la app si las notificaciones fallan
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Solo mostrar loader al inicio
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Usar ListenableBuilder para escuchar cambios en el SubscriptionProvider
    return ListenableBuilder(
      listenable: _subscriptionProvider,
      builder: (context, _) {
        // Determinar qué mostrar en cada tab basado en plan activo primero, luego setup
        final Widget dashboardPage = !_subscriptionProvider.hasActivePlan
            ? const SubscriptionRequiredContent(feature: 'dashboard')
            : !_isSetupComplete 
              ? _buildSetupContent(context)
              : const DashboardScreen();
        
        // Páginas con condicionales: primero plan activo, luego setup completo
        final List<Widget> _pages = [
          dashboardPage,
          !_subscriptionProvider.hasActivePlan
            ? const SubscriptionRequiredContent(feature: 'estadísticas')
            : !_isSetupComplete 
              ? _buildSetupIncompleteMessage(context) 
              : StatsScreen(),
          StoreScreen(), // Store siempre accesible
          SettingsScreen(
            onDeviceStatusChanged: () {
              // Callback cuando cambia el estado del dispositivo
              debugPrint('🔄 Device status changed, refreshing...');
              _initializeData();
            },
            onAvatarChanged: () {
              // Callback cuando cambia el avatar
              debugPrint('🔄 Avatar changed, refreshing profile...');
              _initializeData();
            },
          ), // Settings siempre accesible
        ];

        return ChangeNotifierProvider<LocalNotificationsService>.value(
          value: _localNotificationsService,
          child: Container(
            decoration: BoxDecoration(),
            child: Scaffold(
              // Solo mostrar el AppBar con notificaciones si hay un plan activo
              appBar: _buildAppBar(context, _localNotificationsService),
              // Si no hay un plan activo, restringir contenido
              body: _pages[_currentIndex],
              bottomNavigationBar: _buildBottomNavigationBar(theme),
              // Solo mostrar el botón de chat si hay un plan activo
              floatingActionButton: _subscriptionProvider.hasActivePlan ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                backgroundColor: const Color(0xFFEDE954),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ) : null,
            ),
          ),
        );
      },
    );
  }

  // El método _shouldShowAppBar ya está definido más abajo

  PreferredSizeWidget? _buildAppBar(BuildContext context, LocalNotificationsService notificationService) {
    // No mostrar AppBar si no es una de las tabs que lo requieren
    if (!_shouldShowAppBar(_currentIndex)) {
      return null;
    }

    // Store (índice 2) siempre muestra el AppBar
    // Dashboard (0) y Stats (1) muestran el AppBar solo si hay plan activo
    if (_currentIndex != 2 && !_subscriptionProvider.hasActivePlan) {
      return null;
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(90),
      child: ModernAppBar(
        userName: _userProfile?.username ?? 'Usuario',
        avatarUrl: _userProfile?.avatar,
        unreadCount: notificationService.unreadCount,
        showNotifications: _subscriptionProvider.hasActivePlan, // Ocultar notificaciones si no hay plan activo
        onNotificationPressed: () {
          // Solo permitir acceso a notificaciones si tiene plan activo
          if (_subscriptionProvider.hasActivePlan) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<LocalNotificationsService>.value(
                  value: _localNotificationsService,
                  child: const NotificationsScreen(),
                ),
              ),
            );
          } else {
            // Mostrar pantalla de suscripción requerida
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SubscriptionRequiredScreen(feature: 'notificaciones'),
              ),
            );
          }
        },
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
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Color(0xFF252734),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.square_grid_2x2, size: 24),
              label: AppLocalizations.of(context)!['dashboard']['overview'],
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar, size: 24),
              label: AppLocalizations.of(context)!['dashboard']['stats'],
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.shopping_cart, size: 24),
              label: AppLocalizations.of(context)!['dashboard']['store'],
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.gear, size: 24),
              label: AppLocalizations.of(context)!['dashboard']['settings'],
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
                // Logo y título
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo_2.png',
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!['dashboard']['configurationSetup'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!['dashboard']['completeAllSteps'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                // Items de configuración
                _buildSetupItem(
                  label: AppLocalizations.of(context)!['dashboard']['device'],
                  status: _subscriptionProvider.hasActivePlan 
                    ? (_setupStatusService.currentStatus.hasDevice 
                        ? AppLocalizations.of(context)!['dashboard']['deviceConnected'] 
                        : AppLocalizations.of(context)!['dashboard']['deviceNotConnected'])
                    : 'Requiere suscripción',
                  statusColor: _subscriptionProvider.hasActivePlan
                    ? (_setupStatusService.currentStatus.hasDevice ? Colors.green : Colors.red)
                    : Colors.orange,
                  icon: _subscriptionProvider.hasActivePlan 
                    ? CupertinoIcons.device_phone_portrait
                    : CupertinoIcons.lock_fill,
                  isConnected: _setupStatusService.currentStatus.hasDevice && _subscriptionProvider.hasActivePlan,
                  onTap: () {
                    // Verificar si tiene plan activo antes de permitir conectar un dispositivo
                    if (!_subscriptionProvider.hasActivePlan) {
                      // Mostrar pantalla de suscripción requerida
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionRequiredScreen(feature: 'conexión de dispositivos'),
                        ),
                      );
                      return;
                    }
                    
                    setState(() => _currentIndex = 3);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!['dashboard']['connectDeviceSnackbar']),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSetupItem(
                  label: AppLocalizations.of(context)!['dashboard']['profile'],
                  status: _setupStatusService.currentStatus.hasProfile ? AppLocalizations.of(context)!['dashboard']['profileConnected'] : AppLocalizations.of(context)!['dashboard']['deviceNotConnected'],
                  statusColor: _setupStatusService.currentStatus.hasProfile ? Colors.green : Colors.red,
                  icon: CupertinoIcons.person,
                  isConnected: _setupStatusService.currentStatus.hasProfile,
                  onTap: () {
                    setState(() => _currentIndex = 3);
                    // Refrescar después de un tiempo
                    Future.delayed(const Duration(seconds: 2), () {
                      _initializeData();
                    });
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupItem({
    required String label,
    required String status,
    required Color statusColor,
    required IconData icon,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 30, color: statusColor),
            ),
            const SizedBox(width: 16),
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
            if (isConnected)
              const Icon(Icons.check_circle, size: 24, color: Colors.green),
          ],
        ),
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
              CupertinoIcons.info_circle,
              size: 80,
              color: Colors.blue.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!['dashboard']['setupIncomplete'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!['dashboard']['setupIncompleteDesc'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowAppBar(int index) {
    return index == 0 || index == 1 || index == 2;
  }
}
