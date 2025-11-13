import 'package:flutter/foundation.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:get_it/get_it.dart';

/// Proveedor centralizado para el estado de autenticación
/// Maneja la verificación de sesión de forma segura sin causar Navigator locks
class AuthStateProvider extends ChangeNotifier {
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  final AuthService _authService = GetIt.instance<AuthService>();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Inicializar el estado de autenticación al arrancar la app
  /// Se llama una sola vez en main.dart
  Future<void> initializeAuthState() async {
    try {
      debugPrint('🔐 Inicializando estado de autenticación...');
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verificar si hay token guardado
      final token = await _userStorageService.getJWTToken();
      
      if (token != null && token.isNotEmpty) {
        debugPrint('✅ Token encontrado, verificando validez...');
        
        // Intentar obtener el perfil para validar el token
        try {
          final profile = await _authService.getMyProfile(token: token);
          _isAuthenticated = true;
          debugPrint('✅ Token válido - Usuario autenticado: ${profile.username}');
        } catch (e) {
          debugPrint('❌ Token inválido o expirado: $e');
          // Token inválido, limpiar almacenamiento
          await _userStorageService.clearAllStorage();
          _isAuthenticated = false;
        }
      } else {
        debugPrint('⚠️ No hay token guardado');
        _isAuthenticated = false;
      }
    } catch (e) {
      debugPrint('💥 Error inicializando autenticación: $e');
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marcar como autenticado después de login exitoso
  void setAuthenticated() {
    _isAuthenticated = true;
    _error = null;
    notifyListeners();
    debugPrint('✅ Usuario marcado como autenticado');
  }

  /// Marcar como no autenticado después de logout
  void setUnauthenticated() {
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
    debugPrint('🚪 Usuario marcado como no autenticado');
  }

  /// Limpiar estado
  void reset() {
    _isAuthenticated = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
