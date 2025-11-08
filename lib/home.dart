import 'package:flutter/material.dart';
import 'package:genius_hormo/views/dashboard/dashboard.dart';
import 'package:genius_hormo/views/settings/settings.dart';
import 'package:genius_hormo/views/stats/stats.dart';
import 'package:genius_hormo/views/store/store.dart';
import 'package:genius_hormo/widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Páginas correspondientes a cada tab
  final List<Widget> _pages = [
    DashboardPage(),
    StatsPage(),
    StoreScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(

      ),
      child: Scaffold(
        // Top Bar Personalizada
        // appBar: ModernAppBar(userName: 'Manuel'),
        appBar: _shouldShowAppBar(_currentIndex)
            ? ModernAppBar(userName: "Manuel")
            : null,

        // Cuerpo principal - página actual
        body: _pages[_currentIndex],

        // Bottom Navigation Bar
        bottomNavigationBar: _buildBottomNavigationBar(theme),
      ),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          top: BorderSide(
            // color: Colors.grey[700]!,
            // width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

bool _shouldShowAppBar(int index) {
  // Define en qué páginas mostrar el AppBar
  return index == 0 ||  index == 1 || index ==2; // Ejemplo: no mostrar en ProfilePage
}
