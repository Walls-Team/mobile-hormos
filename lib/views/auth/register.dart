import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/utils/constants.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/form/password_input.dart';
import 'package:genius_hormo/widgets/form/text_input.dart';
import 'terms_and_conditions.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
    );

    if (result == true) {
      setState(() {
        _acceptTerms = true;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debes aceptar los términos y condiciones'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simular proceso de registro
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso!'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );

      // Navegar al login después del registro exitoso
      Navigator.pop(context);
    }
  }

  bool _isButtonEnabled() => _acceptTerms && !_isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 10.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHormoIcon(theme),

              _buildWelcomeMessage(),

              Text('Username', style: TextStyle(color: Colors.white)),
              _buildUsernameField(context),

              Text('Email', style: TextStyle(color: Colors.white)),
              _buildEmailField(),

              Text('Password', style: TextStyle(color: Colors.white)),
              _buildPasswordField(),

              Text('Confirm Password', style: TextStyle(color: Colors.white)),
              _buildConfirmPasswordField(),

              _buildPasswordRequirements(),

              _buildTermsAndConditions(theme),
              SizedBox(height: 30),
              _buildRegisterButton(theme),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHormoIcon(ThemeData theme) {
    return Center(
      child: Image.asset(
        'assets/images/logo_2.png', // Asegúrate de tener esta imagen en tus assets
        // width: 200,
        // height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Register Genius Testosterone',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // color: Colors.black,
            ),
          ),
          const Text(
            'Good to see you.',
            style: TextStyle(
              fontSize: 14,
              // fontWeight: FontWeight.bold,
              // color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return InputText(
      controller: _usernameController,
      hintText: 'user',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un nombre de usuario';
        }
        if (value.length < 3) {
          return 'El usuario debe tener al menos 3 caracteres';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Solo se permiten letras, números y guiones bajos';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return InputText(
      controller: _emailController,
      hintText: 'you@example.com',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Por favor ingresa un email válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return InputPassword(
      controller: _passwordController,
      hintText: '********',
      onChanged: (value) {
        setState(() {}); // Para actualizar los requisitos en tiempo real
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        if (value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres';
        }
        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
          return 'Debe contener mayúsculas, minúsculas y números';
        }
        return null;
      },
    );
  }

  // NUEVO: Widget de requisitos de contraseña (igual al de reset password)
  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    // Solo mostrar si el campo de contraseña tiene texto
    if (password.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de la contraseña:',
            style: TextStyle(
              // color: Colors.grey[300],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          _buildRequirementItem('Al menos 8 caracteres', password.length >= 8),
          _buildRequirementItem(
            'Una letra mayúscula',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'Una letra minúscula',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirementItem('Un número', RegExp(r'\d').hasMatch(password)),
          _buildRequirementItem(
            'Un carácter especial (!@#\$%^&*)',
            RegExp(r'[!@#\$%^&*]').hasMatch(password),
            isRecommended: true,
          ),
        ],
      ),
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

  Widget _buildConfirmPasswordField() {
    return InputPassword(
      controller: _confirmPasswordController,
      hintText: '********',
      onChanged: (value) {
        setState(() {}); // Para actualizar los requisitos en tiempo real
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor confirma tu contraseña';
        }
        if (value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  Widget _buildTermsAndConditions(ThemeData theme) {
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
                  Text('Acepto los ', style: TextStyle(color: Colors.white)),
                  GestureDetector(
                    onTap: _navigateToTermsAndConditions,
                    child: Text(
                      'términos y condiciones',
                      style: TextStyle(
                        // color: theme.primaryColor,
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

  Widget _buildRegisterButton(ThemeData theme) {
    bool isEnabled = _isButtonEnabled();

    return CustomElevatedButton(
      onPressed: isEnabled ? _submitForm : null,
      child: _isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Text('Registrarse', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
