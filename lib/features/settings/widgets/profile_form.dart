// import 'package:flutter/material.dart';
// import '../../models/profile_model.dart';
// import '../../services/profile_service.dart';
// import '../../utils/constants.dart';

// class ProfileForm extends StatefulWidget {
//   const ProfileForm({super.key});

//   @override
//   State<ProfileForm> createState() => _ProfileFormState();
// }

// class _ProfileFormState extends State<ProfileForm> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _userController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _birthDateController = TextEditingController();

//   bool _isLoading = true;
//   bool _isFormValid = false;

//   final Map<String, bool> _filledFields = {
//     'user': false,
//     'gender': true,
//     'height': false,
//     'weight': false,
//     'birthDate': true,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileData();
//   }

//   Future<void> _loadProfileData() async {

//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _profile.birthDate,
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null && picked != _profile.birthDate) {
//       setState(() {
//         _profile = _profile.copyWith(birthDate: picked);
//         _birthDateController.text = _formatDate(picked);
//         _filledFields['birthDate'] = true;
//         _checkFormValidity();
//       });
//     }
//   }

//   void _checkFormValidity() {
//     final isAllFieldsFilled = _filledFields.values.every(
//       (isFilled) => isFilled,
//     );
//     setState(() {
//       _isFormValid = isAllFieldsFilled;
//     });
//   }

//   void _updateFieldFilled(String fieldName, String value) {
//     bool isFilled = value.trim().isNotEmpty;

//     if (fieldName == 'height' || fieldName == 'weight') {
//       final numericValue = double.tryParse(value);
//       isFilled = numericValue != null && numericValue > 0;
//     }

//     setState(() {
//       _filledFields[fieldName] = isFilled;
//     });
//     _checkFormValidity();
//   }

//   void _saveProfile() {
//     if (_formKey.currentState!.validate() && _isFormValid) {
//       _formKey.currentState!.save();
//       _profileService.saveProfile(_profile);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Perfil guardado exitosamente',
//             style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
//           ),
//           backgroundColor: Colors.yellow[700],
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _userController.dispose();
//     _heightController.dispose();
//     _weightController.dispose();
//     _birthDateController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Form(
//       key: _formKey,
//       child: Column(
//         spacing: 20,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Campo User (editable)
//           Text('User', style: theme.textTheme.bodyMedium),
//           TextFormField(
//             controller: _userController,
//             decoration: InputDecorations.textFormFieldDecoration(
//               'User',
//               context,
//             ),
//             validator: Validators.requiredField,
//             onChanged: (value) {
//               _updateFieldFilled('user', value);
//             },
//             onSaved: (value) {
//               _profile = _profile.copyWith(user: value!);
//             },
//             style: const TextStyle(color: Colors.white),
//           ),

//           // Campo Password (fijo) - NO SELECCIONABLE
//           Text('Password', style: theme.textTheme.bodyMedium),

//           IgnorePointer(
//             child: Opacity(
//               opacity: 0.7,
//               child: TextFormField(
//                 initialValue: _profile.password,
//                 decoration: InputDecorations.disabledFieldDecoration(
//                   'Contraseña',
//                   Icons.lock,
//                   context,
//                 ),
//                 readOnly: true,
//                 obscureText: true,
//                 enableInteractiveSelection: false,
//                 showCursor: false,
//                 style: const TextStyle(color: Colors.white70),
//               ),
//             ),
//           ),

//           Text('Gender', style: theme.textTheme.bodyMedium),

//           // Campo Género (editable)
//           DropdownButtonFormField<String>(
//             initialValue: _profile.gender,
//             decoration: InputDecorations.dropdownDecoration(context),
//             items: AppConstants.genders.map((String gender) {
//               return DropdownMenuItem<String>(
//                 value: gender,
//                 child: Text(
//                   gender,
//                   // style: const TextStyle(color: Colors.white),
//                 ),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 setState(() {
//                   _profile = _profile.copyWith(gender: newValue);
//                   _filledFields['gender'] = true;
//                   _checkFormValidity();
//                 });
//               }
//             },
//             validator: Validators.requiredField,
//             dropdownColor: Colors.grey[900],
//             style: const TextStyle(color: Colors.white),
//           ),

//           Text('Height (ft)', style: theme.textTheme.bodyMedium),

//           // Campo Altura (editable)
//           TextFormField(
//             controller: _heightController,
//             decoration: InputDecorations.heightDecoration(context),
//             keyboardType: TextInputType.numberWithOptions(decimal: true),
//             validator: Validators.validateHeight,
//             onChanged: (value) {
//               _updateFieldFilled('height', value);
//             },
//             onSaved: (value) {
//               if (value != null && value.isNotEmpty) {
//                 _profile = _profile.copyWith(height: double.parse(value));
//               }
//             },
//             style: const TextStyle(color: Colors.white),
//           ),

//           Text('Weight (lb)', style: theme.textTheme.bodyMedium),

//           // Campo Peso (editable)
//           TextFormField(
//             controller: _weightController,
//             decoration: InputDecorations.weightDecoration(context),
//             keyboardType: TextInputType.numberWithOptions(decimal: true),
//             validator: Validators.validateWeight,
//             onChanged: (value) {
//               _updateFieldFilled('weight', value);
//             },
//             onSaved: (value) {
//               if (value != null && value.isNotEmpty) {
//                 _profile = _profile.copyWith(weight: double.parse(value));
//               }
//             },
//             style: const TextStyle(color: Colors.white),
//           ),

//           Text('Date of Bird', style: theme.textTheme.bodyMedium),

//           // Campo Fecha de Nacimiento (editable)
//           TextFormField(
//             controller: _birthDateController,
//             decoration: InputDecorations.birthDateDecoration(context),
//             readOnly: true,
//             onTap: () => _selectDate(context),
//             validator: Validators.requiredField,
//             style: const TextStyle(color: Colors.white),
//           ),
//           // Botón Guardar - Solo se activa cuando todos los campos están llenos
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isFormValid ? _saveProfile : null,
//               style: _isFormValid
//                   ? AppButtonStyles.infoButton
//                   : AppButtonStyles.disabledButton,
//               child: const Text(
//                 'Guardar Cambios',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/settings/widgets/avatar_selector_modal.dart';
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
    // Validar que el género esté en la lista, si no usar 'male' por defecto
    // Manejar strings vacíos también
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
        
        // Llamar al servicio para actualizar
        await _authService.updateProfile(
          token: token,
          updatedData: updatedData,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Perfil actualizado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        widget.onSubmit(updatedData);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $e'),
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

  bool _isProfileComplete() {
    return _usernameController.text.isNotEmpty &&
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
              'Toca el avatar para cambiarlo',
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            // Campo Username
            Text('Username'),
            TextFormField(controller: _usernameController),

            Text('Height'),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Altura inválida';
                  }
                }
                return null;
              },
            ),
            Text('Weight'),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Peso inválido';
                  }
                }
                return null;
              },
            ),

            Text('BirthDay'),
            // Campo Birth Date
            TextFormField(
              controller: _birthDateController,

              onTap: () async {
                // Opcional: puedes agregar un date picker aquí
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  _birthDateController.text =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
                  return 'Por favor selecciona un género';
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
          
          // Actualizar avatar inmediatamente
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
        
        // Recargar el perfil para actualizar el header
        await _reloadProfile();
        
        // Notificar al parent que el avatar cambió
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
        debugPrint('🔄 Perfil recargado con nuevo avatar');
      }
    } catch (e) {
      debugPrint('⚠️ Error recargando perfil: $e');
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
        return 'Masculino';
      case 'female':
        return 'Femenino';
      case 'other':
        return 'Otro';
      default:
        return gender;
    }
  }
}
