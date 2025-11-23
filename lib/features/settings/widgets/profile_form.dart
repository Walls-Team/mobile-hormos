import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/widgets/avatar_selector_modal.dart';
import 'package:genius_hormo/features/settings/widgets/language_selector.dart';
import 'package:get_it/get_it.dart';

class UserProfileForm extends StatefulWidget {
  final UserProfileData initialData;
  final void Function(UserProfileData) onSubmit;
  final VoidCallback? onAvatarChanged;

  const UserProfileForm({
    super.key,
    required this.initialData,
    required this.onSubmit,
    this.onAvatarChanged,
  });

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = GetIt.instance<AuthService>();
  final UserStorageService _storageService = GetIt.instance<UserStorageService>();

  late TextEditingController _usernameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthDateController;
  late String _selectedLanguage;
  late String _selectedGender;
  late int? _age;
  String? _selectedAvatar;
  
  bool _isSaving = false;

  // Listas de opciones para los dropdowns
  final List<String> _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los valores del initialData
    _usernameController = TextEditingController(
      text: widget.initialData.username,
    );
    _heightController = TextEditingController(
      text: widget.initialData.height?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.initialData.weight?.toString() ?? '',
    );
    _birthDateController = TextEditingController(
      text: widget.initialData.birthDate ?? '',
    );

    _selectedLanguage = widget.initialData.language;
    // Validate that gender is in the list, if not use 'male' as default
    // Handle empty strings too
    final genderValue = widget.initialData.gender.trim();
    _selectedGender = (genderValue.isNotEmpty && _genders.contains(genderValue)) 
        ? genderValue 
        : 'male';
    _age = widget.initialData.age;
    _selectedAvatar = widget.initialData.avatar;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate required fields first
    if (!_validateRequiredFields()) {
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final token = await _storageService.getJWTToken();
        if (token == null) {
          throw Exception('No token available');
        }

        final updatedData = UserProfileData(
          id: widget.initialData.id,
          username: _usernameController.text,
          email: widget.initialData.email,
          height: _heightController.text.isNotEmpty
              ? double.tryParse(_heightController.text)
              : null,
          weight: _weightController.text.isNotEmpty
              ? double.tryParse(_weightController.text)
              : null,
          language: _selectedLanguage,
          avatar: _selectedAvatar,
          birthDate: _birthDateController.text.isNotEmpty
              ? _birthDateController.text
              : null,
          gender: _selectedGender,
          age: _age,
          isComplete: _isProfileComplete(),
          profileCompletionPercentage: _calculateCompletionPercentage(),
        );
        
        debugPrint('💾 Actualizando perfil...');
        debugPrint('Username: ${updatedData.username}');
        debugPrint('Height: ${updatedData.height}');
        debugPrint('Weight: ${updatedData.weight}');
        debugPrint('BirthDate: ${updatedData.birthDate}');
        debugPrint('Gender: ${updatedData.gender}');
        
        // Llamar al servicio para actualizar (retorna UserProfileData o lanza excepción)
        final result = await _authService.updateProfile(
          token: token,
          updatedData: updatedData,
        );
        
        // Si llegamos aquí, el update fue exitoso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Notify parent with updated data
        widget.onSubmit(result);
      } catch (e) {
        debugPrint('💥 Error updating profile: $e');
        if (mounted) {
          // Try to parse backend error
          final errorMessage = _parseErrorMessage(e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }
  
  bool _validateRequiredFields() {
    List<String> missingFields = [];
    
    if (_usernameController.text.trim().isEmpty) {
      missingFields.add('Username');
    }
    if (_heightController.text.trim().isEmpty) {
      missingFields.add('Height');
    }
    if (_weightController.text.trim().isEmpty) {
      missingFields.add('Weight');
    }
    if (_birthDateController.text.trim().isEmpty) {
      missingFields.add('BirthDay');
    }
    if (_selectedGender.isEmpty) {
      missingFields.add('Gender');
    }
    
    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Please complete: ${missingFields.join(", ")}'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    
    return true;
  }
  
  void _showBackendErrors(String? error) {
    if (error == null) return;
    
    try {
      // Try to parse error as JSON from backend
      final Map<String, dynamic>? errorData = _parseBackendError(error);
      
      if (errorData != null && errorData.containsKey('error')) {
        final errors = errorData['error'] as Map<String, dynamic>;
        List<String> errorMessages = [];
        
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          }
        });
        
        if (errorMessages.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('❌ Validation Errors:', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  ...errorMessages.map((msg) => Text('• $msg')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error parsing backend error: $e');
    }
    
    // Fallback: show raw error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $error'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  Map<String, dynamic>? _parseBackendError(String error) {
    try {
      // Search for JSON in error string
      final jsonStart = error.indexOf('{');
      final jsonEnd = error.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = error.substring(jsonStart, jsonEnd + 1);
        return Map<String, dynamic>.from(
          // We would need dart:convert but for now return null
          {} // TODO: parse JSON if necessary
        );
      }
    } catch (e) {
      debugPrint('Error parsing JSON: $e');
    }
    return null;
  }
  
  String _parseErrorMessage(String error) {
    // Extract readable message from error
    if (error.contains('altura') || error.contains('height')) {
      return 'Height must be between 3.0 and 9.0 ft';
    }
    if (error.contains('peso') || error.contains('weight')) {
      return 'Weight must be at least 40.0 lbs';
    }
    return error;
  }

  bool _isProfileComplete() {
    return _usernameController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _birthDateController.text.isNotEmpty &&
        _selectedLanguage.isNotEmpty &&
        _selectedGender.isNotEmpty;
  }

  double _calculateCompletionPercentage() {
    int completedFields = 0;
    int totalFields = 4; // username, language, gender, birthDate

    if (_usernameController.text.isNotEmpty) completedFields++;
    if (_selectedLanguage.isNotEmpty) completedFields++;
    if (_selectedGender.isNotEmpty) completedFields++;
    if (_birthDateController.text.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.0,
          children: [
            GestureDetector(
              onTap: _showAvatarSelector,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildAvatar(size: 100.0, imageUrl: _selectedAvatar),
                  Positioned(
                    bottom: 0,
                    right: MediaQuery.of(context).size.width / 2 - 62,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF1E1E2C), width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap avatar to change it',
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            // Username field
            Text('Username'),
            TextFormField(controller: _usernameController),

            Text('Height'),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Height is required';
                }
                final height = double.tryParse(value);
                if (height == null) {
                  return 'Please enter a valid number';
                }
                if (height < 3.0 || height > 9.0) {
                  return 'Height must be between 3.0 and 9.0 ft';
                }
                return null;
              },
            ),
            Text('Weight'),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Weight is required';
                }
                final weight = double.tryParse(value);
                if (weight == null) {
                  return 'Please enter a valid number';
                }
                if (weight < 40.0) {
                  return 'Weight must be at least 40.0 lbs';
                }
                return null;
              },
            ),

            Text('BirthDay'),
            // Birth Date field
            TextFormField(
              controller: _birthDateController,
              readOnly: true,
              onTap: () async {
                // Calculate maximum date (18 years ago from today)
                final DateTime maxDate = DateTime.now().subtract(Duration(days: 18 * 365));
                
                final date = await showDatePicker(
                  context: context,
                  initialDate: maxDate,
                  firstDate: DateTime(1900),
                  lastDate: maxDate, // Don't allow dates under 18 years old
                  helpText: 'Select your birth date',
                  errorFormatText: 'Invalid date',
                );
                if (date != null) {
                  _birthDateController.text =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Birth date is required';
                }
                
                // Validate date format
                try {
                  final parts = value.split('-');
                  if (parts.length != 3) {
                    return 'Invalid date format';
                  }
                  
                  final year = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final day = int.parse(parts[2]);
                  final birthDate = DateTime(year, month, day);
                  
                  // Calcular edad
                  final today = DateTime.now();
                  var age = today.year - birthDate.year;
                  if (today.month < birthDate.month || 
                      (today.month == birthDate.month && today.day < birthDate.day)) {
                    age--;
                  }
                  
                  if (age < 18) {
                    return 'You must be at least 18 years old';
                  }
                  
                  return null;
                } catch (e) {
                  return 'Invalid date format';
                }
              },
            ),

            Text('Gender'),
            // Dropdown Gender
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              items: _genders.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(_getGenderDisplayName(gender)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a gender';
                }
                return null;
              },
            ),

            // Botón de enviar
            ElevatedButton(
              onPressed: _isSaving ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Data',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            
            const SizedBox(height: 20),
            
            // Selector de idioma
            const LanguageSelector(),
          ],
        ),
      ),
    );
  }

  void _showAvatarSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AvatarSelectorModal(
        currentAvatarUrl: _selectedAvatar,
        onAvatarSelected: (String avatarUrl) async {
          setState(() {
            _selectedAvatar = avatarUrl;
          });
          
          // Update avatar immediately
          await _updateAvatar(avatarUrl);
        },
      ),
    );
  }

  Future<void> _updateAvatar(String avatarUrl) async {
    try {
      final token = await _storageService.getJWTToken();
      if (token == null) {
        throw Exception('No token available');
      }

      final result = await _authService.updateAvatar(
        token: token,
        avatarUrl: avatarUrl,
      );

      if (mounted && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Avatar updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Reload profile to update header
        await _reloadProfile();
        
        // Notify parent that avatar changed
        widget.onAvatarChanged?.call();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error updating avatar'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _reloadProfile() async {
    try {
      final token = await _storageService.getJWTToken();
      if (token != null) {
        final updatedProfile = await _authService.getMyProfile(token: token);
        // El perfil ya se guarda en caché dentro de getMyProfile
        debugPrint('🔄 Profile reloaded with new avatar');
      }
    } catch (e) {
      debugPrint('⚠️ Error reloading profile: $e');
    }
  }

  Widget _buildAvatar({required size, required String? imageUrl}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl == null ? Colors.grey[800] : null,
        image: imageUrl != null 
            ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null
          ? Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.grey[600],
            )
          : null,
    );
  }

  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      default:
        return gender;
    }
  }
}
