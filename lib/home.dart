import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/dto/health_data.dart';
import 'package:genius_hormo/features/dashboard/pages/dashboard.dart';
import 'package:genius_hormo/features/dashboard/services/dashboard_service.dart';
import 'package:genius_hormo/features/settings/settings.dart';
import 'package:genius_hormo/features/stats/stats.dart';
import 'package:genius_hormo/features/store/store.dart';
import 'package:genius_hormo/widgets/app_bar.dart';
import 'package:get_it/get_it.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = GetIt.instance<AuthService>();
  final DashBoardService _dashBoardService = GetIt.instance<DashBoardService>();
  final UserStorageService _storageService = GetIt.instance<UserStorageService>();

  // Variables para almacenar los datos
  UserProfileData? _userProfile;
  HealthData? _healthData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Inicializar datos después del primer frame para evitar problemas en hot restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    // NO setear _isLoading = true aquí porque ya inicia en true
    debugPrint('📱 Cargando datos del usuario...');

    try {
      final token = await _storageService.getJWTToken();
      
      if (token != null) {
        // Intentar cargar datos, pero NO fallar si hay error
        try {
          final healthData = await _dashBoardService.getHealthData(token: token);
          final userProfile = await _authService.getMyProfile(token: token);
          
          if (mounted) {
            setState(() {
              _userProfile = userProfile;
              _healthData = healthData;
            });
          }
          debugPrint('✅ Datos cargados exitosamente');
        } catch (e) {
          debugPrint('⚠️ Error cargando datos: $e');
          // NO setear error, solo log
        }
      } else {
        debugPrint('⚠️ No hay token disponible');
      }
      
    } catch (e) {
      debugPrint('❌ Error crítico: $e');
    }
    
    // SIEMPRE mostrar la UI al final
    if (mounted) {
      setState(() {
        _isLoading = false;
        _error = null; // Limpiar cualquier error
      });
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

    // SIEMPRE mostrar bottom navigation, sin importar errores
    // Las páginas individuales manejarán datos nulos
    final List<Widget> _pages = [
      DashboardScreen(),
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
      child: Container(
        decoration: BoxDecoration(),
        child: Scaffold(
          appBar: _shouldShowAppBar(_currentIndex)
              ? ModernAppBar(userName: _userProfile?.username ?? 'Usuario', 
              // avatarUrl: _userProfile?.avatar,
               )
              : null,
          body: _pages[_currentIndex],
          bottomNavigationBar: _buildBottomNavigationBar(theme),
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
}

bool _shouldShowAppBar(int index) {
  return index == 0 || index == 1 || index == 2;
}
