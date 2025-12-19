import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/core/auth/auth_state_provider.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/forgot_password.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/auth/services/biometric_auth_service.dart';
import 'package:genius_hormo/features/auth/widgets/biometric_login_button.dart';
import 'package:genius_hormo/features/auth/utils/validators/email_validator.dart';
import 'package:genius_hormo/features/auth/utils/validators/password_validator.dart';
import 'package:genius_hormo/features/auth/pages/setup_screen.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/welcome.dart';
import 'package:genius_hormo/features/auth/widgets/form/password_input.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final UserStorageService _userStorageServic =
      GetIt.instance<UserStorageService>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final BiometricAuthService _biometricService = GetIt.instance<BiometricAuthService>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showEnableBiometricDialog(String email, String password) async {
    final biometricType = await _biometricService.getBiometricTypeMessage();
    
    if (!mounted) return;
    
    final shouldEnable = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔐 Habilitar $biometricType'),
        content: Text(
          '¿Deseas habilitar $biometricType para iniciar sesión más rápido en el futuro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Habilitar'),
          ),
        ],
      ),
    );
    
    if (shouldEnable == true) {
      debugPrint('👆 Usuario eligió habilitar biometría');
      final success = await _biometricService.enableBiometricAuth(
        email: email,
        password: password,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $biometricType habilitado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No se pudo habilitar la autenticación biométrica'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      debugPrint('👎 Usuario eligió no habilitar biometría');
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String email = _emailController.text;
        final String password = _passwordController.text;

        debugPrint('📝 INICIANDO LOGIN');
        debugPrint('📧 Email: $email');

        final ApiResponse<LoginResponse> loginResponse = await _authService
            .login(email, password);

        debugPrint('✅ RESPUESTA RECIBIDA');
        debugPrint('📊 Success: ${loginResponse.success}');
        debugPrint('💬 Message: ${loginResponse.message}');
        debugPrint('❌ Error: ${loginResponse.error}');

        setState(() {
          _isLoading = false;
        });

        if (loginResponse.success) {
          debugPrint('🎉 LOGIN EXITOSO');
          final data = loginResponse.data;

          if (data != null) {
            debugPrint('💾 Guardando tokens...');
            _userStorageServic.saveJWTToken(data.accessToken);
            _userStorageServic.saveRefreshToken(data.refreshToken);
            debugPrint('✅ Tokens guardados');
            
            // Intentar obtener perfil, pero NO fallar si falla
            debugPrint('👤 Obteniendo perfil...');
            try {
              final userProfile = await _authService.getMyProfile(token: data.accessToken);
              debugPrint('✅ Perfil obtenido');
              debugPrint('📋 Perfil completo: ${userProfile.isComplete}');
            } catch (profileError) {
              debugPrint('⚠️ Error obteniendo perfil (continuando login): $profileError');
              // NO mostramos error al usuario, solo en logs
            }

            // Marcar como autenticado en el AuthStateProvider
            final authStateProvider = GetIt.instance<AuthStateProvider>();
            authStateProvider.setAuthenticated();
            debugPrint('✅ AuthStateProvider actualizado');

            // NO navegar inmediatamente - esperar a que se complete el build
            Future.microtask(() async {
              if (!mounted) return;
              
              // Preguntar si quiere habilitar biometría (solo si no está ya habilitada)
              final biometricEnabled = await _biometricService.isBiometricEnabled();
              final biometricAvailable = await _biometricService.isBiometricAvailable();
              
              if (!biometricEnabled && biometricAvailable && mounted) {
                await _showEnableBiometricDialog(
                  _emailController.text,
                  _passwordController.text,
                );
              }
              
              if (!mounted) return;
              debugPrint('✅ Navegando a Dashboard (login exitoso)');
              SafeNavigation.go(context, privateRoutes.dashboard);
              debugPrint('✅ NAVEGACIÓN COMPLETADA');
            });
          }
        } else {
          debugPrint('❌ LOGIN FALLÓ: ${loginResponse.error}');
          // Mostrar error de login
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loginResponse.error ?? AppLocalizations.of(context)!['auth']['loginScreen']['loginErrorGeneric']),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('💥 EXCEPCIÓN: $e');
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!['auth']['loginScreen']['connectionError']}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            SafeNavigation.go(context, publicRoutes.home);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         kToolbarHeight,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LOGO ARRIBA (ocultar cuando el teclado está visible)
                  if (!keyboardVisible) _buildLogoSection(),

                  // FORMULARIO EN EL CENTRO
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Form(key: _formKey, child: _buildLoginForm()),
                  ),

                  // BOTONES ABAJO
                  _buildBottomButtonsSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [_buildLoginIcon(), _buildWelcomeMessage(context)],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      spacing: 10.0,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(AppLocalizations.of(context)!['auth']['email']),
            TextFormField(
              controller: _emailController,
              validator: validateEmail,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!['auth']['loginScreen']['emailPlaceholder']),
            ),
          ],
        ),

        // Campo Password
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(AppLocalizations.of(context)!['auth']['password']),
            InputPassword(
              controller: _passwordController,
              hintText: AppLocalizations.of(context)!['auth']['loginScreen']['passwordPlaceholder'],
              validator: validatePassword,
            ),
          ],
        ),

        // Forgot Password
        _buildForgotPassword(),
      ],
    );
  }

  Widget _buildBottomButtonsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
      child: Column(
        spacing: 10.0,
        children: [
          // Botón Login
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[900]!,
                        ),
                      ),
                    )
                  : Text(AppLocalizations.of(context)!['auth']['loginScreen']['loginButton']),
            ),
          ),

          // Botón de Face ID / Touch ID (solo aparece si está habilitado)
          const BiometricLoginButton(),

          // Botón Register
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                SafeNavigation.goNamed(context, 'register');
              },
              child: Text(AppLocalizations.of(context)!['auth']['loginScreen']['registerButton']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginIcon() {
    return Center(
      child: Image.asset(
        'assets/images/logo_2.png',
        height: 80, // Ajusta según necesites
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!['auth']['loginScreen']['title'],
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!['auth']['loginScreen']['subtitle'],
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            SafeNavigation.goNamed(context, 'forgot_password');
          },
          child: Text(
            AppLocalizations.of(context)!['auth']['loginScreen']['forgotPassword'],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
