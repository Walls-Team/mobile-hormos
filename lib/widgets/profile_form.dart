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
//   final ProfileService _profileService = ProfileService();

//   Profile _profile = Profile(
//     user: '',
//     email: 'usuario@ejemplo.com',
//     password: '********',
//     gender: 'Masculino',
//     height: 0.0,
//     weight: 0.0,
//     birthDate: DateTime.now(),
//   );

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
//     try {
//       final loadedProfile = await _profileService.getProfile();
//       setState(() {
//         _profile = loadedProfile;
//         _initializeControllers();
//         _isLoading = false;
//         _checkFormValidity();
//       });
//     } catch (e) {
//       setState(() {
//         _initializeControllers();
//         _isLoading = false;
//         _checkFormValidity();
//       });
//     }
//   }

//   void _initializeControllers() {
//     _userController.text = _profile.user;
//     _heightController.text = _profile.height > 0
//         ? _profile.height.toStringAsFixed(1)
//         : '';
//     _weightController.text = _profile.weight > 0
//         ? _profile.weight.toStringAsFixed(1)
//         : '';
//     _birthDateController.text = _formatDate(_profile.birthDate);

//     _filledFields['user'] = _profile.user.isNotEmpty;
//     _filledFields['height'] = _profile.height > 0;
//     _filledFields['weight'] = _profile.weight > 0;
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
