import 'dart:async';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/pages/email_verification/email_verified.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

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

  final AuthService _authService = GetIt.instance<AuthService>();


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

      debugPrint('📝 INICIANDO VERIFICACIÓN DE EMAIL');
      debugPrint('📧 Email: ${widget.email}');
      debugPrint('🔐 Código: $verificationCode');

      // Llamar al servicio de verificación de email
      final result = await _authService.verifyEmail(
        email: widget.email, // Asumiendo que recibes el email como parámetro
        code: verificationCode,
      );

      debugPrint('✅ RESPUESTA RECIBIDA');
      debugPrint('📊 Success: ${result.success}');
      debugPrint('💬 Message: ${result.message}');
      debugPrint('❌ Error: ${result.error}');

      setState(() {
        _isLoading = false;
      });

      if (result.success == true) {
        debugPrint('🎉 VERIFICACIÓN EXITOSA');
        
        // Mostrar mensaje de éxito
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!['auth']['emailVerification']['verifySuccess'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        
        // Esperar un momento para que el usuario vea el mensaje
        await Future.delayed(Duration(seconds: 2));
        
        // Verificación exitosa - ir directamente al login
        Future.microtask(() {
          if (!mounted) return;
          context.goNamed('login');
          debugPrint('✅ NAVEGACIÓN COMPLETADA');
        });
      } else {
        debugPrint('❌ VERIFICACIÓN FALLÓ: ${result.error}');
        // Error en la verificación
        setState(() {
          isButtonEnabled = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? AppLocalizations.of(context)!['auth']['emailVerification']['verifyError']),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          // Opcional: Limpiar los campos para nuevo intento
          _clearAllFields();
        }
      }
    } catch (e) {
      debugPrint('💥 EXCEPCIÓN: $e');
      setState(() {
        _isLoading = false;
        isButtonEnabled = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!['auth']['emailVerification']['connectionError']}: $e'),
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
      debugPrint('📝 INICIANDO REENVÍO DE CÓDIGO');
      debugPrint('📧 Email: ${widget.email}');
      debugPrint('🔄 Context: verify');

      // Llamar al servicio para reenviar el OTP
      final result = await _authService.resendOtp(
        email: widget.email,
        context: 'verify'
      );

      debugPrint('✅ RESPUESTA RECIBIDA');
      debugPrint('📊 Success: ${result.success}');
      debugPrint('💬 Message: ${result.message}');
      debugPrint('❌ Error: ${result.error}');

      setState(() {
        _isResending = false;
      });

      if (result.success == true) {
        debugPrint('🎉 REENVÍO EXITOSO');
        // Reenvío exitoso
        setState(() {
          _resendCountdown = 30; // 30 segundos de espera
        });

        _startResendCountdown();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? AppLocalizations.of(context)!['auth']['emailVerification']['resendSuccess']),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('❌ REENVÍO FALLÓ: ${result.error}');
        // Error en el reenvío
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? AppLocalizations.of(context)!['auth']['emailVerification']['resendError']),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('💥 EXCEPCIÓN: $e');
      setState(() {
        _isResending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!['auth']['emailVerification']['connectionError']}: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildLogoSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  // ✅ ELIMINAR ConstrainedBox
                  children: [
                    _buildCodeInputs(), // Tu método CORREGIDO
                    SizedBox(height: 20),
                    _buildResendCode(theme),
                  ],
                ),
              ),
            ),
            _buildBottomButtonsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInputs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return Container(
            width: 50, // ✅ 50px (6 × 50 = 300px < 353px)
            height: 65, // ✅ Un poco más alto
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 22, // ✅ Tamaño legible
                fontWeight:
                    FontWeight.w600, // ✅ Más grueso para mejor visibilidad
              ),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[700]!),
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                ), // ✅ Padding vertical adecuado
              ),
              onChanged: (value) => _onCodeChanged(value, index),
            ),
          );
        }),
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
            AppLocalizations.of(context)!['auth']['emailVerification']['enterCodeTitle'],
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!['auth']['emailVerification']['sentCodeMessage']} ${widget.email}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResendCode(ThemeData theme) {
    return Column(
      children: [
        _resendCountdown > 0
            ? Text(
                '${AppLocalizations.of(context)!['auth']['emailVerification']['resendIn']} $_resendCountdown ${AppLocalizations.of(context)!['auth']['emailVerification']['seconds']}',
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
                        AppLocalizations.of(context)!['auth']['emailVerification']['resendButton'],
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
                      AppLocalizations.of(context)!['auth']['emailVerification']['sendButton'],
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
