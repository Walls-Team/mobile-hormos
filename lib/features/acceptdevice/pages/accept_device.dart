import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AcceptDeviceScreen extends StatefulWidget {
  const AcceptDeviceScreen({super.key});

  @override
  State<AcceptDeviceScreen> createState() => _AcceptDeviceScreenState();
}

class _AcceptDeviceScreenState extends State<AcceptDeviceScreen> {
  final SpikeApiService _spikeService = GetIt.instance<SpikeApiService>();
  final UserStorageService _userStorage = GetIt.instance<UserStorageService>();
  
  bool _isLoading = true;
  bool _success = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _sendConsent();
  }

  Future<void> _sendConsent() async {
    try {
      // Obtener el token del usuario
      final token = await _userStorage.getJWTToken();
      
      if (token == null) {
        setState(() {
          _isLoading = false;
          _success = false;
          _message = 'Authentication token not found';
        });
        return;
      }

      // Send consent to the backend
      final response = await _spikeService.consentCallback(
        token: token,
        consentGiven: true,
      );

      setState(() {
        _isLoading = false;
        _success = response.success;
        _message = response.success 
            ? 'Device connected successfully' 
            : response.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _success = false;
        _message = 'Error connecting device: $e';
      });
    }
  }

  void _goToDashboard() {
    Future.microtask(() {
      if (!mounted) return;
      context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEB3B), // Amarillo como en la imagen
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono de estado
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  )
                else if (_success)
                  const Icon(
                    Icons.check_circle_outline,
                    size: 120,
                    color: Colors.green,
                  )
                else
                  const Icon(
                    Icons.error_outline,
                    size: 120,
                    color: Colors.red,
                  ),
                
                const SizedBox(height: 40),

                // Título
                Text(
                  _isLoading 
                      ? 'Connecting device...'
                      : _success 
                          ? 'Device Connected!'
                          : 'Connection Error',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),

                // Mensaje
                if (!_isLoading)
                  Text(
                    _message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                
                const SizedBox(height: 48),

                // Botón para ir al dashboard
                if (_success && !_isLoading)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToDashboard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Go to Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Botón de reintentar en caso de error
                if (!_success && !_isLoading)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                            });
                            _sendConsent();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _goToDashboard,
                        child: const Text(
                          'Go to Dashboard anyway',
                          style: TextStyle(
                            color: Colors.black87,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}