import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/biometric_auth_service.dart';
import 'package:get_it/get_it.dart';

class BiometricSettings extends StatefulWidget {
  final String? userEmail;
  final String? userPassword; // Solo se usa si el usuario lo ha guardado previamente
  
  const BiometricSettings({
    super.key,
    this.userEmail,
    this.userPassword,
  });

  @override
  State<BiometricSettings> createState() => _BiometricSettingsState();
}

class _BiometricSettingsState extends State<BiometricSettings> {
  final BiometricAuthService _biometricService = GetIt.instance<BiometricAuthService>();
  
  bool _isAvailable = false;
  bool _isEnabled = false;
  bool _isLoading = true;
  String _biometricType = 'Autenticación biométrica';
  
  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }
  
  Future<void> _loadBiometricStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    final type = await _biometricService.getBiometricTypeMessage();
    
    if (mounted) {
      setState(() {
        _isAvailable = available;
        _isEnabled = enabled;
        _biometricType = type;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _toggleBiometric(bool value) async {
    if (!value) {
      // Deshabilitar biometría
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Deshabilitar biometría'),
          content: Text(
            '¿Estás seguro de que deseas deshabilitar $_biometricType?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Deshabilitar'),
            ),
          ],
        ),
      );
      
      if (shouldDisable == true) {
        await _biometricService.disableBiometricAuth();
        if (mounted) {
          setState(() {
            _isEnabled = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autenticación biométrica deshabilitada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      // Habilitar biometría - necesita credenciales
      // Mostrar diálogo para ingresar contraseña
      _showEnableBiometricDialog();
    }
  }
  
  Future<void> _showEnableBiometricDialog() async {
    final emailController = TextEditingController(text: widget.userEmail ?? '');
    final passwordController = TextEditingController();
    
    final credentials = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Habilitar $_biometricType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa tu contraseña para habilitar $_biometricType',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty && 
                  passwordController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  'email': emailController.text,
                  'password': passwordController.text,
                });
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    
    if (credentials != null) {
      final success = await _biometricService.enableBiometricAuth(
        email: credentials['email']!,
        password: credentials['password']!,
      );
      
      if (mounted) {
        if (success) {
          setState(() {
            _isEnabled = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $_biometricType habilitado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ No se pudo habilitar $_biometricType'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Material(
        color: Colors.transparent,
        child: const ListTile(
          leading: Icon(Icons.fingerprint),
          title: Text('Cargando...'),
          trailing: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_isAvailable) {
      return const SizedBox.shrink(); // No mostrar si no está disponible
    }
    
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
      secondary: Icon(
        _biometricType.contains('Face') ? Icons.face : Icons.fingerprint,
        color: _isEnabled ? Colors.blue : Colors.grey,
      ),
      title: Text(_biometricType),
      subtitle: Text(
        _isEnabled 
          ? 'Inicio rápido habilitado'
          : 'Permite iniciar sesión más rápido',
      ),
      value: _isEnabled,
      onChanged: _toggleBiometric,
      ),
    );
  }
}
