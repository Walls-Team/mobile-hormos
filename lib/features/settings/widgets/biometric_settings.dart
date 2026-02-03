import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/biometric_auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

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
  String _biometricType = '';
  
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
    final type = await _biometricService.getBiometricTypeMessage(context);
    
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
      final localizations = AppLocalizations.of(context)!;
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations['biometric']['disableTitle']),
          content: Text(
            '${localizations['biometric']['disableMessage']} $_biometricType?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations['biometric']['cancel']),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(localizations['biometric']['disable']),
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
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations['biometric']['authenticationDisabled']),
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
    final localizations = AppLocalizations.of(context)!;
    final emailController = TextEditingController(text: widget.userEmail ?? '');
    final passwordController = TextEditingController();
    
    final credentials = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${localizations['biometric']['enableTitle']} $_biometricType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${localizations['biometric']['enableMessage']} $_biometricType',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: localizations['biometric']['email'],
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: localizations['biometric']['password'],
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations['biometric']['cancel']),
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
            child: Text(localizations['biometric']['continue']),
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
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $_biometricType ${localizations['biometric']['enabledSuccessfully']}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${localizations['biometric']['couldNotEnable']} $_biometricType'),
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
      final localizations = AppLocalizations.of(context)!;
      return Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(Icons.fingerprint),
          title: Text(localizations['biometric']['loading']),
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
      title: Text(_biometricType.isEmpty ? AppLocalizations.of(context)!['biometric']['authenticationTitle'] : _biometricType),
      subtitle: Text(
        _isEnabled 
          ? AppLocalizations.of(context)!['biometric']['quickLoginEnabled']
          : AppLocalizations.of(context)!['biometric']['allowQuickLogin'],
      ),
      value: _isEnabled,
      onChanged: _toggleBiometric,
      ),
    );
  }
}
