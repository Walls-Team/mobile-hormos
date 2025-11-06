import 'package:flutter/material.dart';
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
  final TextEditingController _confirmPasswordController = TextEditingController();
  
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
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Crear Cuenta'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildRegisterIcon(theme),
              SizedBox(height: 30),
              _buildUsernameField(),
              SizedBox(height: 20),
              _buildEmailField(),
              SizedBox(height: 20),
              _buildPasswordField(),
              SizedBox(height: 10),
              // NUEVO: Widget de requisitos de contraseña
              _buildPasswordRequirements(),
              SizedBox(height: 20),
              _buildConfirmPasswordField(),
              SizedBox(height: 20),
              _buildTermsAndConditions(theme),
              SizedBox(height: 30),
              _buildRegisterButton(theme),
              SizedBox(height: 20),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterIcon(ThemeData theme) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_add,
        size: 50,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Nombre de usuario',
        prefixIcon: Icon(Icons.person),
      ),
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
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: Icon(Icons.email),
      ),
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
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
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
      onChanged: (value) {
        setState(() {}); // Para actualizar los requisitos en tiempo real
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requisitos de la contraseña:',
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          _buildRequirementItem(
            'Al menos 8 caracteres',
            password.length >= 8,
          ),
          _buildRequirementItem(
            'Una letra mayúscula',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'Una letra minúscula',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirementItem(
            'Un número',
            RegExp(r'\d').hasMatch(password),
          ),
          _buildRequirementItem(
            'Un carácter especial (!@#\$%^&*)',
            RegExp(r'[!@#\$%^&*]').hasMatch(password),
            isRecommended: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet, {bool isRecommended = false}) {
    Color iconColor;
    Color textColor;
    
    if (isMet) {
      iconColor = Colors.green;
      textColor = Colors.green;
    } else if (isRecommended) {
      iconColor = Colors.orange;
      textColor = Colors.orange;
    } else {
      iconColor = Colors.grey[500]!;
      textColor = Colors.grey[400]!;
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: iconColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontStyle: isRecommended && !isMet ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Confirmar contraseña',
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
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
                  Text(
                    'Acepto los ',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _navigateToTermsAndConditions,
                    child: Text(
                      'términos y condiciones',
                      style: TextStyle(
                        color: theme.primaryColor,
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
    
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isEnabled ? _submitForm : null,
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                ),
              )
            : Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿Ya tienes una cuenta?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        SizedBox(width: 5),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Inicia sesión'),
        ),
      ],
    );
  }
}