import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/forgot_password.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/views/auth/register.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';
import 'package:genius_hormo/widgets/buttons/outlined_button.dart';
import 'package:genius_hormo/widgets/form/password_input.dart';
import 'package:genius_hormo/widgets/form/text_input.dart';

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // En login_screen.dart, actualiza el método _submitForm:
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Login exitoso!'),
      //     backgroundColor: Theme.of(context).primaryColor,
      //     behavior: SnackBarBehavior.floating,

      //   ),
      // );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
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
        // title: Text('Iniciar Sesión'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // ← Space Between
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,

                spacing: 12.0,
                children: [
                  _buildLoginIcon(theme),

                  _buildWelcomeMessage(),

                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  InputText(
                    controller: _emailController,
                    hintText: 'you@example.com',
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ingresa tu email';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),

                  const Text(
                    'Password',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),

                  InputPassword(
                    controller: _passwordController,
                    hintText: '********',
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ingresa tu contraseña';
                      if (value.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  _buildRememberMeForgot(theme),

                  _buildActionButtons(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginIcon(ThemeData theme) {
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
            'Log In Genius Testosterone',
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

  // En login_screen.dart, actualiza el método _buildRememberMeForgot:
  Widget _buildRememberMeForgot(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Checkbox(
            //   value: _rememberMe,
            //   onChanged: (value) {
            //     setState(() {
            //       _rememberMe = value!;
            //     });
            //   },
            // ),
            // Text('Recordarme', style: TextStyle(color: theme.hintColor)),
          ],
        ),
        TextButton(
          onPressed: () {
            // Navegar a la pantalla de recuperación de contraseña
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            );
          },
          child: Text(
            '¿Forgot Password?',
            style: TextStyle(
              // color: Colors.white,
              color: Theme.of(context).colorScheme.onSurface,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      spacing: 10.0,
      children: [
        CustomElevatedButton(
          onPressed: _isLoading ? () {} : _submitForm,
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
              : const Text(
                  'Log In',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),

        CustomOutlinedButton(
          borderColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegistrationForm()),
            );
          },
          child: const Text(
            'Register',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
