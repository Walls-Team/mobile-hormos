import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para manejar autenticación biométrica (Face ID, Touch ID, Huella)
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _savedEmailKey = 'biometric_email';
  static const String _savedPasswordKey = 'biometric_password';
  
  /// Verifica si el dispositivo soporta biometría
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('❌ Error verificando soporte biométrico: $e');
      return false;
    }
  }
  
  /// Verifica si hay biometría disponible (configurada en el dispositivo)
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;
      
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      return canCheckBiometrics;
    } catch (e) {
      debugPrint('❌ Error verificando disponibilidad biométrica: $e');
      return false;
    }
  }
  
  /// Obtiene los tipos de biometría disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('❌ Error obteniendo biometrías disponibles: $e');
      return [];
    }
  }
  
  /// Muestra un mensaje amigable del tipo de biometría disponible
  Future<String> getBiometricTypeMessage() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Huella digital';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Reconocimiento de iris';
    } else {
      return 'Autenticación biométrica';
    }
  }
  
  /// Autentica al usuario usando biometría
  Future<bool> authenticate({
    String localizedReason = 'Por favor autentíquese para continuar',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('⚠️ Biometría no disponible en este dispositivo');
        return false;
      }
      
      debugPrint('🔐 Iniciando autenticación biométrica...');
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false, // Permite PIN como fallback
        ),
      );
      
      if (authenticated) {
        debugPrint('✅ Autenticación biométrica exitosa');
      } else {
        debugPrint('❌ Autenticación biométrica fallida');
      }
      
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('💥 Error en autenticación biométrica: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado en autenticación biométrica: $e');
      return false;
    }
  }
  
  /// Verifica si el usuario tiene habilitada la autenticación biométrica
  Future<bool> isBiometricEnabled() async {
    try {
      debugPrint('🔍 Leyendo flag de biometría habilitada...');
      final enabled = await _secureStorage.read(key: _biometricEnabledKey);
      debugPrint('   Valor leído: $enabled');
      final result = enabled == 'true';
      debugPrint('   Resultado: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Error verificando si biometría está habilitada: $e');
      return false;
    }
  }
  
  /// Habilita la autenticación biométrica y guarda las credenciales
  Future<bool> enableBiometricAuth({
    required String email,
    required String password,
  }) async {
    try {
      // Primero, verificar que la biometría está disponible
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        debugPrint('⚠️ No se puede habilitar: biometría no disponible');
        return false;
      }
      
      // Solicitar autenticación para confirmar
      final authenticated = await authenticate(
        localizedReason: 'Autentíquese para habilitar el inicio rápido',
      );
      
      if (!authenticated) {
        debugPrint('❌ Usuario no se autenticó, no se habilitará biometría');
        return false;
      }
      
      // Guardar credenciales de forma segura
      debugPrint('💾 Guardando credenciales biométricas...');
      debugPrint('   Email: $email');
      await _secureStorage.write(key: _savedEmailKey, value: email);
      debugPrint('   ✅ Email guardado');
      await _secureStorage.write(key: _savedPasswordKey, value: password);
      debugPrint('   ✅ Password guardado');
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      debugPrint('   ✅ Flag de habilitación guardado');
      
      // Verificar que se guardó correctamente
      final savedEmail = await _secureStorage.read(key: _savedEmailKey);
      final savedEnabled = await _secureStorage.read(key: _biometricEnabledKey);
      debugPrint('🔍 Verificación de guardado:');
      debugPrint('   Email guardado: ${savedEmail != null ? "✅" : "❌"}');
      debugPrint('   Habilitación guardada: ${savedEnabled == "true" ? "✅" : "❌"}');
      
      debugPrint('✅ Autenticación biométrica habilitada exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ Error habilitando autenticación biométrica: $e');
      return false;
    }
  }
  
  /// Deshabilita la autenticación biométrica y elimina las credenciales
  Future<void> disableBiometricAuth() async {
    try {
      await _secureStorage.delete(key: _savedEmailKey);
      await _secureStorage.delete(key: _savedPasswordKey);
      await _secureStorage.delete(key: _biometricEnabledKey);
      debugPrint('✅ Autenticación biométrica deshabilitada');
    } catch (e) {
      debugPrint('❌ Error deshabilitando autenticación biométrica: $e');
    }
  }
  
  /// Obtiene las credenciales guardadas después de autenticación exitosa
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        debugPrint('⚠️ Biometría no habilitada, no hay credenciales guardadas');
        return null;
      }
      
      final email = await _secureStorage.read(key: _savedEmailKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);
      
      if (email == null || password == null) {
        debugPrint('⚠️ Credenciales no encontradas');
        return null;
      }
      
      return {
        'email': email,
        'password': password,
      };
    } catch (e) {
      debugPrint('❌ Error obteniendo credenciales guardadas: $e');
      return null;
    }
  }
  
  /// Login rápido con biometría
  /// Autentica con biometría y devuelve las credenciales si es exitoso
  Future<Map<String, String>?> quickLoginWithBiometric({
    String localizedReason = 'Autentíquese para iniciar sesión',
  }) async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        debugPrint('⚠️ Autenticación biométrica no habilitada');
        return null;
      }
      
      // Autenticar con biometría
      final authenticated = await authenticate(
        localizedReason: localizedReason,
      );
      
      if (!authenticated) {
        debugPrint('❌ Autenticación biométrica fallida');
        return null;
      }
      
      // Si la autenticación fue exitosa, devolver credenciales
      return await getSavedCredentials();
    } catch (e) {
      debugPrint('❌ Error en login rápido biométrico: $e');
      return null;
    }
  }
  
  /// Obtiene el email guardado (sin autenticar, solo para mostrar)
  Future<String?> getSavedEmail() async {
    try {
      debugPrint('📧 Obteniendo email guardado...');
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        debugPrint('   Biometría no habilitada, no hay email guardado');
        return null;
      }
      
      final email = await _secureStorage.read(key: _savedEmailKey);
      debugPrint('   Email leído: ${email ?? "null"}');
      return email;
    } catch (e) {
      debugPrint('❌ Error obteniendo email guardado: $e');
      return null;
    }
  }
}
