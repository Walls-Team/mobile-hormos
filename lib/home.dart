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
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await _storageService.getJWTToken();
      
      if (token == null) {
        throw Exception('No token available');
      }

      final healthData = await _dashBoardService.getHealthData(token: token);
      final userProfile = await _authService.getMyProfile(token: token);
      
      setState(() {
        _userProfile = userProfile;
        _healthData = healthData;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Loading state
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error: $_error'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeData,
                child: Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Success state - _userProfile nunca será null aquí
    final List<Widget> _pages = [
      DashboardScreen(),
      StatsPage(),
      StoreScreen(),
      SettingsScreen(),
    ];

    return Container(
      decoration: BoxDecoration(),
      child: Scaffold(
        appBar: _shouldShowAppBar(_currentIndex)
            ? ModernAppBar(userName: _userProfile!.username, 
            // avatarUrl: _userProfile!.avatar!,
             )
            : null,
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shopping_cart),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

bool _shouldShowAppBar(int index) {
  return index == 0 || index == 1 || index == 2;
}
