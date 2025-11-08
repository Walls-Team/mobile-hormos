// import 'package:flutter/material.dart';
// import 'package:genius_hormo/views/auth/pages/forgot_password.dart';
// import 'package:genius_hormo/home.dart';
// import 'package:genius_hormo/features/auth/pages/register.dart';
// import 'package:genius_hormo/widgets/form/password_input.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       await Future.delayed(Duration(seconds: 2));
//       setState(() {
//         _isLoading = false;
//       });

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.close),
//           onPressed: () => Navigator.pop(context),
//         ),
//         // title: Text('Iniciar Sesión'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceBetween, // ← Space Between
//             children: [
//               Column(

//                 spacing: 12.0,
//                 children: [
//                   _buildLoginIcon(),
//                   _buildWelcomeMessage(context),

//                   const Text(
//                     'Password',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),

//                   TextFormField(
//                     controller: _emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Ingresa tu email';
//                       }
//                       if (!RegExp(
//                         r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                       ).hasMatch(value)) {
//                         return 'Email inválido';
//                       }
//                       return null;
//                     },
//                     decoration: InputDecoration(hintText: 'you@example.com'),
//                   ),

//                   const Text(
//                     'Password',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                   ),

//                   InputPassword(
//                     controller: _passwordController,
//                     hintText: '********',
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Ingresa tu contraseña';
//                       }
//                       if (value.length < 6) return 'Mínimo 6 caracteres';
//                       return null;
//                     },
//                   ),

//                   _buildForgotPassword(),
//                   _buildActionButtons(),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoginIcon() {
//     return Center(
//       child: Image.asset(
//         'assets/images/logo_2.png', // Asegúrate de tener esta imagen en tus assets
//         fit: BoxFit.contain,
//       ),
//     );
//   }

//   Widget _buildWelcomeMessage(BuildContext context) {
//     return Center(
//       child: Column(
//         children: [
//           Text(
//             'Log In Genius Testosterone',
//             style: Theme.of(context).textTheme.headlineSmall,
//           ),
//           Text(
//             'Good to see you.',
//             style: Theme.of(context).textTheme.titleSmall,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       spacing: 10.0,
//       children: [
//         ElevatedButton(
//           onPressed: _isLoading ? () {} : _submitForm,
//           child: _isLoading
//               ? SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.grey[900]!,
//                     ),
//                   ),
//                 )
//               : const Text('Log In'),
//         ),

//         OutlinedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => RegisterScreen()),
//             );
//           },
//           child: Text('Log In'),
//         ),
//       ],
//     );
//   }

//   Widget _buildForgotPassword() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         TextButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
//             );
//           },
//           child: Text(
//             '¿Forgot Password?',
//             style: TextStyle(
//               // color: Colors.white,
//               color: Theme.of(context).colorScheme.onSurface,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/pages/forgot_password.dart';
import 'package:genius_hormo/home.dart';
import 'package:genius_hormo/features/auth/pages/register.dart';
import 'package:genius_hormo/widgets/form/password_input.dart';

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribuye el espacio
          children: [
            // LOGO ARRIBA
            _buildLogoSection(),

            // FORMULARIO EN EL CENTRO
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(key: _formKey, child: _buildLoginForm()),
              ),
            ),

            // BOTONES ABAJO
            _buildBottomButtonsSection(context),
          ],
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu email';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Email inválido';
                }
                return null;
              },
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                if (value.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
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
                  : const Text(
                      'Log In',
                    ),
            ),
          ),


          // Botón Register
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text(
                'Register',
              ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            );
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
