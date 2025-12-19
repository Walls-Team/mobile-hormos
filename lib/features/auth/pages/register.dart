import 'package:flutter/material.dart';
import 'package:genius_hormo/app/route_names.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/verify_email_intro.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/utils/validators/email_validator.dart';
import 'package:genius_hormo/features/auth/utils/validators/password_validator.dart';
import 'package:genius_hormo/features/auth/utils/validators/username_validator.dart';
import 'package:genius_hormo/welcome.dart';
import 'package:genius_hormo/features/auth/widgets/form/password_input.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/widgets/terms_conditions_modal.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = GetIt.instance<AuthService>();

  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _navigateToTermsAndConditions() async {
    await TermsConditionsModal.show(context);
    // Marcar como aceptado después de ver los términos
    setState(() {
      _acceptTerms = true;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!['auth']['registerScreen']['mustAcceptTerms']),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        debugPrint('📝 INICIANDO REGISTRO...');
        debugPrint('👤 Username: ${_usernameController.text.trim()}');
        debugPrint('📧 Email: ${_emailController.text.trim()}');
        
        final result = await _authService.register(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        debugPrint('✅ RESPUESTA RECIBIDA');
        debugPrint('📊 Success: ${result.success}');
        debugPrint('💬 Message: ${result.message}');
        debugPrint('❌ Error: ${result.error}');

        setState(() {
          _isLoading = false;
        });

        if (result.success == true) {
          debugPrint('🎉 REGISTRO EXITOSO - Navegando a VerifyEmailIntroScreen');
          // NO navegar inmediatamente - esperar a que se complete el build
          Future.microtask(() {
            if (!mounted) return;
            context.goNamed('verify_email', extra: _emailController.text);
            debugPrint('✅ NAVEGACIÓN COMPLETADA');
          });
        } else {
          debugPrint('❌ REGISTRO FALLÓ: ${result.error}');
          _showErrorDialog(result.error ?? AppLocalizations.of(context)!['auth']['registerScreen']['registerErrorGeneric']);
        }
      } catch (e) {
        debugPrint('💥 EXCEPCIÓN: $e');
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('${AppLocalizations.of(context)!['auth']['registerScreen']['connectionError']}: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!['auth']['registerScreen']['registerErrorTitle']),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!['auth']['registerScreen']['ok']),
          ),
        ],
      ),
    );
  }

  bool _isButtonEnabled() => _acceptTerms && !_isLoading;

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            context.go(publicRoutes.home);
          },
        ),
        // title: Text('Iniciar Sesión'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ocultar logo cuando el teclado está visible
              if (!keyboardVisible) _buildHormoIcon(),
              if (!keyboardVisible) _buildWelcomeMessage(context),

              Text(AppLocalizations.of(context)!['auth']['username']),
              TextFormField(
                controller: _usernameController,
                validator: validateUsername,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!['auth']['registerScreen']['usernamePlaceholder'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              Text(AppLocalizations.of(context)!['auth']['email']),
              TextFormField(
                controller: _emailController,
                validator: validateEmail,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!['auth']['registerScreen']['emailPlaceholder'],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              Text(AppLocalizations.of(context)!['auth']['password']),
              _buildPasswordField(),

              Text(AppLocalizations.of(context)!['auth']['confirmPassword']),
              _buildConfirmPasswordField(),

              _buildPasswordRequirements(),
              _buildTermsAndConditions(),
              _buildRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHormoIcon() {
    return Center(
      child: Image.asset('assets/images/logo_2.png', fit: BoxFit.contain),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!['auth']['registerScreen']['title'],
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            AppLocalizations.of(context)!['auth']['registerScreen']['subtitle'],
            style: Theme.of(context).textTheme.titleSmall?.copyWith(),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!['auth']['registerScreen']['passwordRequirements'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        _buildRequirementItem(AppLocalizations.of(context)!['auth']['registerScreen']['atLeast8Chars'], password.length >= 8),
        _buildRequirementItem(
          AppLocalizations.of(context)!['auth']['registerScreen']['oneUppercase'],
          RegExp(r'[A-Z]').hasMatch(password),
        ),
        _buildRequirementItem(
          AppLocalizations.of(context)!['auth']['registerScreen']['oneLowercase'],
          RegExp(r'[a-z]').hasMatch(password),
        ),
        _buildRequirementItem(AppLocalizations.of(context)!['auth']['registerScreen']['oneNumber'], RegExp(r'\d').hasMatch(password)),
        _buildRequirementItem(
          AppLocalizations.of(context)!['auth']['registerScreen']['oneSpecialChar'],
          RegExp(r'[!@#\$%^&*]').hasMatch(password),
          isRecommended: true,
        ),
      ],
    );
  }

  Widget _buildRequirementItem(
    String text,
    bool isMet, {
    bool isRecommended = false,
  }) {
    Color textColor;

    if (isMet) {
      textColor = Theme.of(context).colorScheme.primary;
    } else {
      textColor = Colors.white;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontStyle: isRecommended && !isMet
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value!;
                });
              },
            ),
            Expanded(
              child: Wrap(
                children: [
                  Text(AppLocalizations.of(context)!['auth']['registerScreen']['iAcceptThe'], style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: _navigateToTermsAndConditions,
                    child: Text(
                      AppLocalizations.of(context)!['auth']['registerScreen']['termsAndConditions'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    bool isEnabled = _isButtonEnabled();

    return ElevatedButton(
      onPressed: isEnabled ? _submitForm : null,

      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : Text(AppLocalizations.of(context)!['auth']['registerScreen']['registerButton']),
    );
  }

  Widget _buildPasswordField() {
    return InputPassword(
      controller: _passwordController,
      hintText: AppLocalizations.of(context)!['auth']['registerScreen']['passwordPlaceholder'],
      onChanged: (value) {
        setState(() {});
      },
      validator: validatePassword,
    );
  }

  Widget _buildConfirmPasswordField() {
    return InputPassword(
      controller: _confirmPasswordController,
      hintText: AppLocalizations.of(context)!['auth']['registerScreen']['passwordPlaceholder'],
      onChanged: (value) {
        setState(() {});
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!['auth']['registerScreen']['confirmPasswordRequired'];
        }
        if (value != _passwordController.text) {
          return AppLocalizations.of(context)!['auth']['registerScreen']['passwordsDoNotMatch'];
        }
        return null;
      },
    );
  }
}
