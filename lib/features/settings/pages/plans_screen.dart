import 'package:flutter/material.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/models/plan.dart';
import 'package:genius_hormo/features/settings/services/plans_api_service.dart';
import 'package:get_it/get_it.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final PlansApiService _plansApiService = GetIt.instance<PlansApiService>();
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  
  bool _isLoading = true;
  String? _error;
  List<Plan>? _plans;
  
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }
  
  Future<void> _loadPlans() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final token = await _userStorageService.getJWTToken();
      
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'No se pudo obtener el token de autenticación';
          _isLoading = false;
        });
        return;
      }
      
      final response = await _plansApiService.getPlans(authToken: token);
      
      if (response.success && response.data != null) {
        setState(() {
          _plans = response.data!.plans;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.error ?? 'Error desconocido';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFF1C1D23),
      appBar: AppBar(
        title: Text('Planes'),
        backgroundColor: Color(0xFF1C1D23),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFEDE954),
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEDE954),
                foregroundColor: Colors.black,
              ),
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (_plans == null || _plans!.isEmpty) {
      return const Center(
        child: Text(
          'No hay planes disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Renderizar planes de la API
          ..._plans!.map((plan) {
              return Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFEDE954), // Amarillo de la app
                  borderRadius: BorderRadius.circular(16), // Puntas redondeadas
                ),
                child: Column(
                  children: [
                    Text(
                      plan.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${plan.price} - ${plan.days} días',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Suscribiéndose al plan ${plan.title}'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Botón negro
                        foregroundColor: Color(0xFFEDE954), // Texto amarillo
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Suscribirse',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
