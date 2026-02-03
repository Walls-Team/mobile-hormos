import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/services/biometric_auth_service.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/core/auth/auth_state_provider.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:local_auth/local_auth.dart';

class BiometricLoginButton extends StatefulWidget {
  const BiometricLoginButton({super.key});

  @override
  State<BiometricLoginButton> createState() => _BiometricLoginButtonState();
}

class _BiometricLoginButtonState extends State<BiometricLoginButton> {
  final BiometricAuthService _biometricService = GetIt.instance<BiometricAuthService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final UserStorageService _userStorageService = GetIt.instance<UserStorageService>();
  final AuthStateProvider _authStateProvider = GetIt.instance<AuthStateProvider>();
  
  bool _isVisible = false;
  bool _isLoading = false;
  String? _savedEmail;
  String _biometricType = 'Face ID';
  
  @override
  void initState() {
    super.initState();
    debugPrint('\n🚀 BiometricLoginButton: initState llamado');
    _checkBiometricAvailability();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔄 BiometricLoginButton: didChangeDependencies llamado');
    // Verificar de nuevo cuando el widget se reconstruye
    _checkBiometricAvailability();
  }
  
  Future<void> _checkBiometricAvailability() async {
    debugPrint('\n🔍 BiometricLoginButton: Verificando disponibilidad...');
    
    final isEnabled = await _biometricService.isBiometricEnabled();
    debugPrint('   Biometría habilitada: $isEnabled');
    
    if (!isEnabled) {
      debugPrint('   ❌ Biometría no habilitada, botón no se mostrará');
      return;
    }
    
    final email = await _biometricService.getSavedEmail();
    debugPrint('   Email guardado: ${email ?? "null"}');
    
    final type = await _biometricService.getBiometricTypeMessage(context);
    debugPrint('   Tipo de biometría: $type');
    
    final willShow = isEnabled && email != null;
    debugPrint('   👁️ Botón se mostrará: $willShow\n');
    
    if (mounted) {
      setState(() {
        _isVisible = willShow;
        _savedEmail = email;
        _biometricType = type;
      });
    }
  }
  
  Future<void> _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Intentar login biométrico
      final localizations = AppLocalizations.of(context)!;
      final credentials = await _biometricService.quickLoginWithBiometric(
        localizedReason: localizations['biometric']['authenticateToLogin'],
      );
      
      if (credentials == null) {
        debugPrint('❌ Autenticación biométrica cancelada o fallida');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Login con las credenciales obtenidas
      debugPrint('🔐 Iniciando login con credenciales biométricas...');
      final loginResponse = await _authService.login(
        credentials['email']!,
        credentials['password']!,
      );
      
      if (loginResponse.success && loginResponse.data != null) {
        debugPrint('✅ Login biométrico exitoso');
        
        // Guardar tokens
        await _userStorageService.saveJWTToken(loginResponse.data!.accessToken);
        await _userStorageService.saveRefreshToken(loginResponse.data!.refreshToken);
        
        // Intentar obtener perfil, pero NO fallar si falla
        try {
          final userProfile = await _authService.getMyProfile(
            token: loginResponse.data!.accessToken,
          );
          debugPrint('✅ Perfil obtenido en login biométrico');
        } catch (profileError) {
          debugPrint('⚠️ Error obteniendo perfil (continuando login biométrico): $profileError');
        }
        
        // Marcar como autenticado
        _authStateProvider.setAuthenticated();
        
        // Navegar al dashboard
        if (mounted) {
          SafeNavigation.go(context, privateRoutes.dashboard);
        }
      } else {
        debugPrint('❌ Login biométrico falló: ${loginResponse.error}');
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginResponse.error ?? localizations['biometric']['loginError']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error en login biométrico: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${localizations['biometric']['error']}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  IconData _getBiometricIcon() {
    // Determinar el icono según el tipo de biometría
    if (_biometricType.contains('Face')) {
      return Icons.face; // Face ID
    } else if (_biometricType.contains('Huella')) {
      return Icons.fingerprint; // Touch ID / Huella
    } else {
      return Icons.lock; // Genérico
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Botón de login biométrico
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleBiometricLogin,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_getBiometricIcon(), size: 24),
            label: Text(
              _isLoading
                  ? 'Autenticando...'
                  : '$_biometricType',
              style: const TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ),
          ),
        ),
        
        // Email guardado con mejor diseño
        if (_savedEmail != null)
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _savedEmail!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Separador con texto
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[700])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[700])),
          ],
        ),
        
        const SizedBox(height: 16),
      ],
    );
  }
}
