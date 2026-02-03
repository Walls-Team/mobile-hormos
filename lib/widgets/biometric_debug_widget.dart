import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/biometric_auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Widget de debugging para verificar el estado de la biometría
class BiometricDebugWidget extends StatefulWidget {
  const BiometricDebugWidget({super.key});

  @override
  State<BiometricDebugWidget> createState() => _BiometricDebugWidgetState();
}

class _BiometricDebugWidgetState extends State<BiometricDebugWidget> {
  final BiometricAuthService _biometricService = GetIt.instance<BiometricAuthService>();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isLoading = true;
  Map<String, dynamic> _debugInfo = {};
  
  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }
  
  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Leer valores directamente del secure storage
      final biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      final savedEmail = await _secureStorage.read(key: 'biometric_email');
      final savedPassword = await _secureStorage.read(key: 'biometric_password');
      
      // Verificar con el servicio
      final isEnabled = await _biometricService.isBiometricEnabled();
      final isAvailable = await _biometricService.isBiometricAvailable();
      final email = await _biometricService.getSavedEmail();
      final biometricType = await _biometricService.getBiometricTypeMessage(context);
      
      setState(() {
        _debugInfo = {
          'Secure Storage': {
            'biometric_enabled': biometricEnabled ?? 'null',
            'biometric_email': savedEmail ?? 'null',
            'biometric_password': savedPassword != null ? '******* (guardado)' : 'null',
          },
          'Service Methods': {
            'isBiometricEnabled()': isEnabled.toString(),
            'isBiometricAvailable()': isAvailable.toString(),
            'getSavedEmail()': email ?? 'null',
            'getBiometricTypeMessage()': biometricType,
          },
          'Expected Behavior': {
            'Botón debe mostrarse': (isEnabled && email != null).toString(),
          },
        };
        _isLoading = false;
      });
      
      debugPrint('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('🔍 BIOMETRIC DEBUG INFO');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('📦 Secure Storage:');
      debugPrint('   biometric_enabled: ${biometricEnabled ?? "null"}');
      debugPrint('   biometric_email: ${savedEmail ?? "null"}');
      debugPrint('   biometric_password: ${savedPassword != null ? "******* (exists)" : "null"}');
      debugPrint('\n📋 Service Methods:');
      debugPrint('   isBiometricEnabled(): $isEnabled');
      debugPrint('   isBiometricAvailable(): $isAvailable');
      debugPrint('   getSavedEmail(): ${email ?? "null"}');
      debugPrint('   getBiometricTypeMessage(): $biometricType');
      debugPrint('\n✅ Expected:');
      debugPrint('   Botón debe mostrarse: ${isEnabled && email != null}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    } catch (e) {
      debugPrint('❌ Error en debug: $e');
      setState(() {
        _debugInfo = {'Error': e.toString()};
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.bug_report, color: Colors.orange),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!['debug']['title']),
        ],
      ),
      content: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!['debug']['verifyingStatus']),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _debugInfo.entries.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      if (section.value is Map)
                        ...(section.value as Map).entries.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item.key}:',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    item.value.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: item.value == 'null' || item.value == 'false'
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!['debug']['close']),
        ),
        ElevatedButton(
          onPressed: () {
            _loadDebugInfo();
          },
          child: Text(AppLocalizations.of(context)!['debug']['reload']),
        ),
      ],
    );
  }
}
