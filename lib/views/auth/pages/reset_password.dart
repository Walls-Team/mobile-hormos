import 'package:flutter/material.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/form/password_input.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // En reset_password_screen.dart, actualiza el método _submitForm:
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simular proceso de reset de contraseña
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _passwordReset = true;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Contraseña restablecida exitosamente!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // NUEVO: Redirección automática a Home después de 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    }
  }

  // Y actualiza el método _navigateToLogin en la pantalla de éxito:
  void _navigateToLogin() {
    // Cambiado: Ahora va al Home en lugar del Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

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
            _buildRegisterButton(theme),
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
          : Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, size: 60, color: Colors.green),
            ),
            SizedBox(height: 30),
            Text(
              '¡Contraseña Restablecida!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'Tu contraseña ha sido cambiada exitosamente. Ahora puedes iniciar sesión con tu nueva contraseña.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                child: Text(
                  'Ir al Inicio de Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {
                // Opcional: Volver al inicio/welcome
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Volver al Inicio', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
