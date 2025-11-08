// // providers/auth_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:genius_hormo/features/auth/models/user_models.dart';
// import 'package:genius_hormo/features/auth/services/auth_provider.dart';

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();
//   User? _currentUser;
//   bool _isLoading = false;
//   String? _error;

//   User? get currentUser => _currentUser;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // Inicializar
//   Future<void> initialize() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final user = await _authService.getCurrentUser();
//       _currentUser = user;
//       _error = null;
//     } catch (e) {
//       _error = 'Error al inicializar: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // REGISTER
//   Future<bool> register({
//     required String username,
//     required String email,
//     required String password,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final result = await _authService.register(
//         username: username,
//         email: email,
//         password: password,
//       );

//       if (result.success) {
//         // Obtener y guardar el usuario actual después del registro
//         _currentUser = await _authService.getCurrentUser();
//         _error = null;
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _error = result.error;
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = 'Error inesperado: $e';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // LOGIN
//   Future<bool> login(String email, String password) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final result = await _authService.login(email, password);

//       if (result.success) {
//         _currentUser = await _authService.getCurrentUser();
//         _error = null;
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         _error = result.error;
//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       _error = 'Error inesperado: $e';
//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // Logout
//   Future<void> logout() async {
//     await _authService.logout();
//     _currentUser = null;
//     _error = null;
//     notifyListeners();
//   }

//   // Verificar estado de autenticación
//   Future<bool> checkAuthStatus() async {
//     return await _authService.isLoggedIn();
//   }


//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
