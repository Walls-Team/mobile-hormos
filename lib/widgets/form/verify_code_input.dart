import 'dart:async';
import 'package:flutter/material.dart';

class VerificationResult {
  final bool success;
  final String? message;
  final String? errorCode;

  VerificationResult({
    required this.success,
    this.message,
    this.errorCode,
  });
}

class VerificationCodeInput extends StatefulWidget {
  final int codeLength;
  final Future<VerificationResult> Function() onRetryEmail;
  final Future<VerificationResult> Function(String code) onSubmit;
  final String email;
  final String buttonText;
  final String title;
  final bool autoSubmit;

  const VerificationCodeInput({
    super.key,
    this.codeLength = 6,
    required this.onRetryEmail,
    required this.onSubmit,
    required this.email,
    this.buttonText = 'Verify Code',
    this.title = 'Enter verification Code',
    this.autoSubmit = true,
  });

  @override
  _VerificationCodeInputState createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controllers y focus nodes
    for (int i = 0; i < widget.codeLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    
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
    _clearError(); // Limpiar error al escribir
    
    if (value.length == 1 && index < widget.codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (widget.autoSubmit && _isAllFieldsFilled()) {
      _submitCode();
    }
  }

  bool _isAllFieldsFilled() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  String _getVerificationCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  Future<void> _submitCode() async {
    if (!_isAllFieldsFilled() || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onSubmit(_getVerificationCode());
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (!result.success) {
          _showError(result.message ?? 'Verification failed');
          _clearAllFields(); // Limpiar campos en caso de error
        }
        // Si es success, el callback onSubmit debería manejar la navegación
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showError('Network error: $e');
        _clearAllFields();
      }
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onRetryEmail();
      
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        
        if (result.success) {
          setState(() {
            _resendCountdown = 30;
          });
          _startResendCountdown();
          _showSuccess('Code sent successfully');
        } else {
          _showError(result.message ?? 'Failed to resend code');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showError('Network error: $e');
      }
    }
  }

  void _clearAllFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 30),

        // Inputs del código
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.codeLength, (index) {
            return SizedBox(
              width: 50,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _errorMessage != null ? Colors.red : null,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _errorMessage != null 
                          ? Colors.red 
                          : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) => _onCodeChanged(value, index),
              ),
            );
          }),
        ),

        // Mensaje de error
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Botón de reenvío
        _buildResendSection(),

        const SizedBox(height: 30),

        // Botón de verificación
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading || !_isAllFieldsFilled() ? null : _submitCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: _errorMessage != null 
                  ? Colors.red 
                  : Theme.of(context).colorScheme.primary,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(widget.buttonText),
          ),
        ),

        const SizedBox(height: 16),

        // Botón para limpiar
        TextButton(
          onPressed: _clearAllFields,
          child: Text('Clear Code'),
        ),
      ],
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Code sent to ${widget.email}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        _resendCountdown > 0
            ? Text(
                'Resend available in $_resendCountdown seconds',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                ),
              )
            : TextButton(
                onPressed: _isResending ? null : _resendCode,
                child: _isResending
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Resend Code',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
      ],
    );
  }
}