import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/email_verified.dart';
import 'package:genius_hormo/features/auth/services/auth_provider.dart';

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
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _setupFocusListeners();
    _setupControllerListeners();
    _startResendCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_updateButtonState);
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _countdownTimer?.cancel();
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

  void _setupControllerListeners() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_updateButtonState);
    }
  }

  void _updateButtonState() {
    final allFilled = _isAllFieldsFilled();

    if (allFilled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = allFilled && !_isLoading;
      });
    }
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();

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
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    _updateButtonState();
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getVerificationCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  // En tu widget donde manejas la verificación de email

  void _verifyCode() async {
    if (!_isAllFieldsFilled() || _isLoading) return;

    setState(() {
      _isLoading = true;
      isButtonEnabled = false;
    });

    try {
      String verificationCode = _getVerificationCodeFromFields();

      // Llamar al servicio de verificación de email
      final result = await AuthService().verifyEmail(
        email: widget.email, // Asumiendo que recibes el email como parámetro
        verificationCode: verificationCode,
      );




      setState(() {
        _isLoading = false;
      });

      if (result.success == true) {
        // Verificación exitosa
        if (mounted) {

          // Navegar a la pantalla de éxito
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerifiedScreen(email: widget.email),
            ),
          );
        }
      } else {
        // Error en la verificación
        setState(() {
          isButtonEnabled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al verificar el código'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // Opcional: Limpiar los campos para nuevo intento
          _clearAllFields();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        isButtonEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Método auxiliar para obtener el código completo de los campos individuales
  String _getVerificationCodeFromFields() {
    return _controllers.map((controller) => controller.text).join();
  }

  // Método para limpiar todos los campos
  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }

    // Mover el foco al primer campo (asumiendo que tienes un array de focusNodes)
    if (_focusNodes.isNotEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes.first);
    }
  }

  void _resendCode() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      // // Llamar al servicio para reenviar el OTP
      final result = await AuthService().resendOtp(
        email: widget.email, // Asumiendo que recibes el email como parámetro
      );

      setState(() {
        _isResending = false;
      });

      if (result.success == true) {
        // Reenvío exitoso
        setState(() {
          _resendCountdown = 30; // 30 segundos de espera
        });

        _startResendCountdown();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? 'Código reenviado exitosamente',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Error en el reenvío
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al reenviar el código'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isResending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // void _resendCode() async {
  //   if (_resendCountdown > 0) return;

  //   setState(() {
  //     _isResending = true;
  //   });

  //   // Simular reenvío de código
  //   await Future.delayed(Duration(seconds: 2));

  //   setState(() {
  //     _isResending = false;
  //     _resendCountdown = 30;
  //   });

  //   _startResendCountdown();

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Código reenviado exitosamente'),
  //       backgroundColor: Theme.of(context).primaryColor,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // LOGO ARRIBA
            _buildLogoSection(),

            // FORMULARIO EN EL CENTRO
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCodeInputs(),
                    SizedBox(height: 20),
                    _buildResendCode(theme),
                  ],
                ),
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

  Widget _buildLoginIcon() {
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
            'Enter verification Code',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
          ),
          const SizedBox(height: 8),
          Text(
            'We have sent a verification code to ${widget.email}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 60,
          child: TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(fontSize: 29),
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

  Widget _buildResendCode(ThemeData theme) {
    return Column(
      children: [
        _resendCountdown > 0
            ? Text(
                'You can resend in $_resendCountdown seconds',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
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
                        "If you didn't receive a code, Resend",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ],
    );
  }

  Widget _buildBottomButtonsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0, left: 20, right: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isButtonEnabled && !_isLoading ? _verifyCode : null,
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
