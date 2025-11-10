// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/profile_model.dart';

// class ProfileService {
//   static const String _profileKey = 'user_profile';

//   Future<Profile> getProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final profileData = prefs.getString(_profileKey);
      
//       if (profileData != null) {
//         // Si tienes datos guardados, aquí los procesarías
//         // Por ahora retornamos un perfil por defecto
//         return _getDefaultProfile();
//       }
      
//       return _getDefaultProfile();
//     } catch (e) {
//       // En caso de error, retornar perfil por defecto
//       return _getDefaultProfile();
//     }
//   }

//   Profile _getDefaultProfile() {
//     return Profile(
//       user: '',
//       email: 'usuario@ejemplo.com',
//       password: '********',
//       gender: 'Masculino',
//       height: 0.0,
//       weight: 0.0,
//       birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)), // 25 años por defecto
//     );
//   }

//   Future<void> saveProfile(Profile profile) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       // Aquí guardarías los datos del perfil
//       // Por ahora solo guardamos un indicador de que hay datos
//       await prefs.setString(_profileKey, 'profile_saved');
//     } catch (e) {
//       // Manejar error de guardado
//       print('Error guardando perfil: $e');
//     }
//   }
// }