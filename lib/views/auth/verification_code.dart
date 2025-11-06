// import 'package:flutter/material.dart';
// import 'package:genius_hormo/views/auth/reset_password.dart';

// class VerificationCodeScreen extends StatefulWidget {
//   final String email;

//   const VerificationCodeScreen({
//     Key? key,
//     required this.email,
//   }) : super(key: key);

//   @override
//   _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
// }

// class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
//   final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
//   bool _isLoading = false;
//   bool _isResending = false;
//   int _resendCountdown = 30;

//   @override
//   void initState() {
//     super.initState();
//     _setupFocusListeners();
//     _startResendCountdown();
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }

//   void _setupFocusListeners() {
//     for (int i = 0; i < _focusNodes.length; i++) {
//       _focusNodes[i].addListener(() {
//         if (!_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
//           if (i > 0) {
//             _focusNodes[i - 1].requestFocus();
//           }
//         }
//       });
//     }
//   }

//   void _startResendCountdown() {
//     Future.delayed(Duration.zero, () {
//       for (int i = _resendCountdown; i > 0; i--) {
//         Future.delayed(Duration(seconds: i), () {
//           if (mounted) {
//             setState(() {
//               _resendCountdown = i - 1;
//             });
//           }
//         });
//       }
//     });
//   }

//   void _onCodeChanged(String value, int index) {
//     if (value.length == 1 && index < 3) {
//       _focusNodes[index + 1].requestFocus();
//     } else if (value.isEmpty && index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }

//     // Verificar si todos los campos están llenos
//     if (_isAllFieldsFilled()) {
//       _verifyCode();
//     }
//   }

//   bool _isAllFieldsFilled() {
//     return _controllers.every((controller) => controller.text.isNotEmpty);
//   }

//   String _getVerificationCode() {
//     return _controllers.map((controller) => controller.text).join();
//   }

//   void _verifyCode() async {
//     if (!_isAllFieldsFilled()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     // Simular verificación del código
//     await Future.delayed(Duration(seconds: 2));

//     setState(() {
//       _isLoading = false;
//     });

//     // Navegar a la pantalla de reset password si el código es correcto
//     // En una app real, aquí verificarías el código con tu backend
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ResetPasswordScreen(
//           email: widget.email,
//           verificationCode: _getVerificationCode(),
//         ),
//       ),
//     );
//   }

//   void _resendCode() async {
//     if (_resendCountdown > 0) return;

//     setState(() {
//       _isResending = true;
//     });

//     // Simular reenvío de código
//     await Future.delayed(Duration(seconds: 2));

//     setState(() {
//       _isResending = false;
//       _resendCountdown = 30;
//     });

//     _startResendCountdown();

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Código reenviado exitosamente'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('Verificar Código'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             SizedBox(height: 40),
//             _buildHeaderIcon(theme),
//             SizedBox(height: 30),
//             _buildInstructions(),
//             SizedBox(height: 40),
//             _buildCodeInputs(),
//             SizedBox(height: 30),
//             _buildVerifyButton(theme),
//             SizedBox(height: 20),
//             _buildResendCode(theme),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderIcon(ThemeData theme) {
//     return Container(
//       width: 100,
//       height: 100,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         shape: BoxShape.circle,
//       ),
//       child: Icon(
//         Icons.sms,
//         size: 50,
//         color: theme.primaryColor,
//       ),
//     );
//   }

//   Widget _buildInstructions() {
//     return Column(
//       children: [
//         Text(
//           'Verificación de Código',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 15),
//         Text(
//           'Hemos enviado un código de 4 dígitos a:',
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[400],
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 5),
//         Text(
//           widget.email,
//           style: TextStyle(
//             fontSize: 16,
//             color: Theme.of(context).primaryColor,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 10),
//         Text(
//           'Ingresa el código que recibiste en tu email',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey[500],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildCodeInputs() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(4, (index) {
//         return SizedBox(
//           width: 60,
//           child: TextFormField(
//             controller: _controllers[index],
//             focusNode: _focusNodes[index],
//             keyboardType: TextInputType.number,
//             textAlign: TextAlign.center,
//             maxLength: 1,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//             decoration: InputDecoration(
//               counterText: '',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                   color: Theme.of(context).primaryColor,
//                   width: 2,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(color: Colors.grey[700]!),
//               ),
//               filled: true,
//               fillColor: Colors.grey[800],
//             ),
//             onChanged: (value) => _onCodeChanged(value, index),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildVerifyButton(ThemeData theme) {
//     return SizedBox(
//       width: double.infinity,
//       height: 55,
//       child: ElevatedButton(
//         onPressed: _isLoading || !_isAllFieldsFilled() ? null : _verifyCode,
//         child: _isLoading
//             ? SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
//                 ),
//               )
//             : Text(
//                 'Verificar Código',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildResendCode(ThemeData theme) {
//     return Column(
//       children: [
//         Text(
//           '¿No recibiste el código?',
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 14,
//           ),
//         ),
//         SizedBox(height: 10),
//         _resendCountdown > 0
//             ? Text(
//                 'Puedes reenviar en $_resendCountdown segundos',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 12,
//                 ),
//               )
//             : TextButton(
//                 onPressed: _isResending ? null : _resendCode,
//                 child: _isResending
//                     ? SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
//                         ),
//                       )
//                     : Text(
//                         'Reenviar Código',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//       ],
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_hormo/views/auth/reset_password.dart';
import 'package:genius_hormo/widgets/buttons/elevated_button.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _setupFocusListeners() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          if (i > 0) {
            _focusNodes[i - 1].requestFocus();
          }
        }
      });
    }
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel(); // Cancelar timer anterior si existe

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      // Cambiado de 3 a 5
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Verificar si todos los campos están llenos
    if (_isAllFieldsFilled()) {
      _verifyCode();
    }
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getVerificationCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  void _verifyCode() async {
    if (!_isAllFieldsFilled()) return;

    setState(() {
      _isLoading = true;
    });

    // Simular verificación del código
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navegar a la pantalla de reset password si el código es correcto
    // En una app real, aquí verificarías el código con tu backend
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(
          email: widget.email,
          verificationCode: _getVerificationCode(),
        ),
      ),
    );
  }

  void _resendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    // Simular reenvío de código
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isResending = false;
      _resendCountdown = 30;
    });

    _startResendCountdown();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código reenviado exitosamente'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          spacing: 40.0,
          children: [
            SizedBox(height: 40),
            _buildHormoIcon(),
            _buildCodeInputs(),
            _buildResendCode(theme),
            _buildVerifyButton(theme),
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

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              filled: true,
              fillColor: Colors.grey[800],
            ),
            onChanged: (value) => _onCodeChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(ThemeData theme) {
    return CustomElevatedButton(
      onPressed: _isLoading || !_isAllFieldsFilled() ? null : _verifyCode,
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
              'Verificar Código',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildResendCode(ThemeData theme) {
    return Column(
      children: [
        Text(
          '¿No recibiste el código?',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        _resendCountdown > 0
            ? Text(
                'Puedes reenviar en $_resendCountdown segundos',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              )
            : TextButton(
                onPressed: _isResending ? null : _resendCode,
                child: _isResending
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primaryColor,
                          ),
                        ),
                      )
                    : Text(
                        'Reenviar Código',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ],
    );
  }
}
