import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/app/safe_navigation.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/dto/login_dto.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/forgot_password.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/auth/utils/validators/email_validator.dart';
import 'package:genius_hormo/features/auth/utils/validators/password_validator.dart';
import 'package:genius_hormo/features/auth/pages/setup_screen.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/welcome.dart';
import 'package:genius_hormo/features/auth/widgets/form/password_input.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            
            debugPrint('👤 Obteniendo perfil...');
            final userProfile = await _authService.getMyProfile(token: data.accessToken);
            debugPrint('✅ Perfil obtenido');
            debugPrint('📋 Perfil completo: ${userProfile.isComplete}');

            // NO navegar inmediatamente - esperar a que se complete el build
            Future.microtask(() {
              if (!mounted) return;
              
              debugPrint('✅ Perfil completo - Navegando a HomeScreen');
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
                content: Text(loginResponse.error ?? 'Error en el login'),
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
              content: Text('Error de conexión: $e'),
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
            Text('Email'),
            TextFormField(
              controller: _emailController,
              validator: validateEmail,
              decoration: InputDecoration(hintText: 'you@example.com'),
            ),
          ],
        ),

        // Campo Password
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text('Password'),
            InputPassword(
              controller: _passwordController,
              hintText: '********',
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
                  : const Text('Log In'),
            ),
          ),

          // Botón Register
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                SafeNavigation.goNamed(context, 'register');
              },
              child: const Text('Register'),
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
            'Log In Genius Testosterone',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Good to see you.',
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
            'Forgot Password?',
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
