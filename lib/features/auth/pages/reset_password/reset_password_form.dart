import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/login.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/utils/validators/password_validator.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/form/password_input.dart';
import 'package:get_it/get_it.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _passwordReset = false;

  final AuthService _authService = GetIt.instance<AuthService>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String newPassword = _passwordController.text;
        final String confirmPassword = _confirmPasswordController.text;

        // Llamar al servicio para confirmar el reset de contraseña
        final resetResponse = await _authService.confirmPasswordReset(
          email: widget.email,
          code: widget.otp,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );

        setState(() {
          _isLoading = false;
        });

        if (resetResponse.success) {
          setState(() {
            _passwordReset = true;
          });
        } else {
          // Mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resetResponse.error ?? 'Error al restablecer la contraseña',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // void _navigateToLogin() {
  //   // Cambiado: Ahora va al Home en lugar del Login
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => HomeScreen()),
  //   );
  // }

  bool _isButtonEnabled() {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _passwordReset
          ? _buildSuccessScreen(theme)
          : _buildResetForm(theme),
    );
  }

  Widget _buildResetForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 20.0,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            _buildHormoIcon(),

            _buildInstructions(),

            Text('Password', style: TextStyle(color: Colors.white)),
            _buildPasswordField(),

            Text('Confirm Password', style: TextStyle(color: Colors.white)),
            _buildConfirmPasswordField(),

            _buildPasswordRequirements(),

            // _buildSubmitButton(theme),
            _buildResetButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHormoIcon() {
    return Center(
      child: Image.asset(
        'assets/images/logo_2.png', // Asegúrate de tener esta imagen en tus assets
        // width: 200,
        // height: 200,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Text(
        'New Password',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPasswordField() {
    return InputPassword(
      controller: _passwordController,
      hintText: '********',
      onChanged: (value) {
        setState(() {}); // Para actualizar los requisitos en tiempo real
      },
      validator: validatePassword,
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    return Column(
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

  Widget _buildResetButton(ThemeData theme) {
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
          : Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Card(
                margin: EdgeInsets.all(30),
                child: Center(
                  child: Column(
                    spacing: 10.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      _buildIcon(context),
                      Text(
                        'You’re ready to go',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      // Mensaje
                      Text(
                        'Password succesfully reseted, \n You’re all set to continue.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Botón en la parte inferior
        Padding(
          padding: EdgeInsets.only(bottom: 60, left: 24, right: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Login'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Espacio entre el borde y el icono interno
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12.0), // Tamaño del círculo interno
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          Icons.check, // o Icons.verified, Icons.done, etc.
          color: Theme.of(context).colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }
}
