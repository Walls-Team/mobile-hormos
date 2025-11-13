import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/pages/reset_password/reset_password_validate_code.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/utils/validators/email_validator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = GetIt.instance<AuthService>();


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      final String email = _emailController.text;

      debugPrint('📧 Solicitando reset de contraseña para: $email');

      final resetResponse = await _authService.requestPasswordReset(
        email: email,
      );

      debugPrint('✅ Respuesta recibida: ${resetResponse.success}');
      debugPrint('💬 Mensaje: ${resetResponse.message}');
      debugPrint('❌ Error: ${resetResponse.error}');

      setState(() {
        _isLoading = false;
      });

      if (resetResponse.success) {
        // Navegar a la pantalla de verificación de código
        Future.microtask(() {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordVerificationCodeScreen(email: email),
            ),
          );
        });
      } else {
        // Mostrar error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resetResponse.error ?? 'Error al enviar el código'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(publicRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LOGO ARRIBA
            _buildLogoSection(),

            // FORMULARIO EN EL CENTRO
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(key: _formKey, child: _buildForgotPasswordForm()),
              ),
            ),

            // BOTÓN ABAJO
            _buildBottomButtonSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Column(
        children: [_buildHormoIcon(), _buildWelcomeMessage(context)],
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      spacing: 20.0,
      children: [
        // Campo Email
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text('Email'),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'you@example.com'),
              validator:validateEmail,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButtonSection(BuildContext context) {
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
                  : const Text('Send'),
            ),
          ),

          // Botón Register
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.goNamed('login');
              },
              child: const Text('Do you have an account?'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHormoIcon() {
    return Center(
      child: Image.asset(
        'assets/images/logo_2.png',
        height: 80,
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
            'Forgot Password',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll send you a verification code',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
