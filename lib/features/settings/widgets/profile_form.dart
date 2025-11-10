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

import 'package:flutter/material.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';

class UserProfileForm extends StatefulWidget {
  final UserProfileData initialData;
  final void Function(UserProfileData) onSubmit;

  const UserProfileForm({
    super.key,
    required this.initialData,
    required this.onSubmit,
  });

  @override
  State<UserProfileForm> createState() => _UserProfileFormState();
}

class _UserProfileFormState extends State<UserProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthDateController;
  late String _selectedLanguage;
  late String _selectedGender;
  late int? _age;

  // Listas de opciones para los dropdowns
  final List<String> _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los valores del initialData
    _usernameController = TextEditingController(
      text: widget.initialData.username,
    );
    _emailController = TextEditingController(
      text: widget.initialData.email ?? '',
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
    _selectedGender = widget.initialData.gender;
    _age = widget.initialData.age;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedData = UserProfileData(
        id: widget.initialData.id,
        username: _usernameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        height: _heightController.text.isNotEmpty
            ? double.tryParse(_heightController.text)
            : null,
        weight: _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        language: _selectedLanguage,
        avatar: widget.initialData.avatar,
        birthDate: _birthDateController.text.isNotEmpty
            ? _birthDateController.text
            : null,
        gender: _selectedGender,
        age: _age,
        isComplete: _isProfileComplete(),
        profileCompletionPercentage: _calculateCompletionPercentage(),
      );

      widget.onSubmit(updatedData);
    }
  }

  bool _isProfileComplete() {
    return _usernameController.text.isNotEmpty &&
        _selectedLanguage.isNotEmpty &&
        _selectedGender.isNotEmpty;
  }

  double _calculateCompletionPercentage() {
    int completedFields = 0;
    int totalFields = 5; // username, email, language, gender, birthDate

    if (_usernameController.text.isNotEmpty) completedFields++;
    if (_emailController.text.isNotEmpty) completedFields++;
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
            _buildAvatar(size: 100.0, imageUrl: widget.initialData.avatar),

            // Campo Username
            Text('Username'),
            TextFormField(controller: _usernameController),

            Text('Email'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
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
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Save Data',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar({required size, required imageUrl}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.contain),
      ),
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
