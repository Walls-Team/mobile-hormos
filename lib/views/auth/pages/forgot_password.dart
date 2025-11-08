import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/pages/verification_code.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/form/text_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

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

      // Simular envío de email
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navegar a la pantalla de verificación de código
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerificationCodeScreen(email: _emailController.text),
        ),
      );
    }
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
      body: Container(
        padding: EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  spacing: 20.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHormoIcon(),

                    _buildMessage(),

                    Text('Email'),
                    _buildEmailField(),

                    _buildSubmitButton(theme),
                  ],
                ),
              ),
            ],
          ),
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

  Widget _buildMessage() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Forgot Password',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return InputText(
      controller: _emailController,
      hintText: 'your@example.com',

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

  Widget _buildSubmitButton(ThemeData theme) {
    return CustomElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
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
          : Text(
              'Enviar Código de Verificación',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
