import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:genius_hormo/features/auth/dto/user_profile_dto.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/providers/lang_service.dart';
import 'package:genius_hormo/features/settings/widgets/avatar_selector_modal.dart';
import 'package:genius_hormo/features/settings/widgets/language_selector.dart';
import 'package:genius_hormo/features/settings/widgets/plans_badge.dart';
import 'package:genius_hormo/features/settings/pages/plans_screen.dart';
import 'package:genius_hormo/providers/subscription_provider.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/features/settings/widgets/height_picker.dart';
import 'package:genius_hormo/features/settings/widgets/weight_picker.dart';

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
  final LanguageService _languageService = GetIt.instance<LanguageService>();
  late StreamSubscription<Locale> _languageSubscription;
  final AuthService _authService = GetIt.instance<AuthService>();
  final UserStorageService _storageService = GetIt.instance<UserStorageService>();
  final SubscriptionProvider _subscriptionProvider = GetIt.instance<SubscriptionProvider>();

  late TextEditingController _usernameController;
  late TextEditingController _birthDateController;
  late String _selectedLanguage;
  late String _selectedGender;
  
  // For height and weight (with defaults in imperial units)
  double _height = 67.0; // Default height in INCHES (5'7" ≈ 67 inches)
  double _weight = 154.0; // Default weight in pounds (70kg ≈ 154 lbs)
  late int? _age;
  String? _selectedAvatar;
  
  bool _isSaving = false;

  // Listas de opciones para los dropdowns
  final List<String> _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController(
      text: widget.initialData.username,
    );
    _birthDateController = TextEditingController(
      text: widget.initialData.birthDate ?? '',
    );
    _selectedGender = widget.initialData.gender ?? '';
    _selectedLanguage = widget.initialData.language ?? 'es';
    _selectedAvatar = widget.initialData.avatar;
    
    // Initialize height and weight from profile with defaults
    // Backend almacena altura en PULGADAS y peso en libras
    if (widget.initialData.height != null) {
      // Si tenemos una altura, la usamos directamente (ya viene en pulgadas)
      _height = widget.initialData.height!;
      debugPrint('📝 ProfileForm - Inicializado con altura desde backend: $_height pulgadas');
    } else {
      // Default: 5'7" = 67 pulgadas
      _height = 67.0;
      debugPrint('📝 ProfileForm - Inicializado con altura predeterminada: $_height pulgadas');
    }
    
    if (widget.initialData.weight != null) {
      // Si tenemos un peso, lo usamos directamente (ya viene en libras)
      _weight = widget.initialData.weight!;
      debugPrint('📝 ProfileForm - Inicializado con peso desde backend: $_weight libras');
    } else {
      // Default: 70kg ≈ 154 libras
      _weight = 154.0;
      debugPrint('📝 ProfileForm - Inicializado con peso predeterminado: $_weight libras');
    }
    
    // Subscribe to language changes
    _languageSubscription = _languageService.currentLocale.listen((locale) {
      if (mounted) {
        // Guardamos los valores actuales antes de cambiar el idioma
        final currentHeight = _height;
        final currentWeight = _weight;
        
        setState(() {
          _selectedLanguage = locale.languageCode;
          // Mantenemos los mismos valores de altura y peso al cambiar de idioma
          _height = currentHeight;
          _weight = currentWeight;
          debugPrint('🌐 Language changed to: ${locale.languageCode}');
          debugPrint('📏 Manteniendo altura: $_height pulgadas');
          debugPrint('⚖️ Manteniendo peso: $_weight lbs');
        });
      }
    });

    _loadPlan();
  }
  
  // Método para cargar datos del plan
  Future<void> _loadPlan() async {
    // Si el plan está cargando o no está inicializado, forzar la actualización
    if (_subscriptionProvider.isLoading || !_subscriptionProvider.hasCheckedPlan) {
      debugPrint('🔄 UserProfileForm: Solicitando actualización del plan...');
      await _subscriptionProvider.fetchCurrentPlan();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _birthDateController.dispose();
    _languageSubscription.cancel();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar si necesitamos actualizar el plan cuando se muestra de nuevo
    if (mounted) {
      _loadPlan();
    }
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
          final localizations = AppLocalizations.of(context)!;
          throw Exception(localizations['settings']['profileForm']['noTokenAvailable']);
        }

        final updatedData = UserProfileData(
          id: widget.initialData.id,
          username: _usernameController.text,
          email: widget.initialData.email,
          height: _height, // En PULGADAS (ej: 67.0 pulgadas)
          weight: _weight, // En formato de libras (150.0)
          language: _selectedLanguage,
          avatar: _selectedAvatar,
          gender: _selectedGender ?? '',
          birthDate: _birthDateController.text,
          isComplete: _isProfileComplete(),
          profileCompletionPercentage: _calculateCompletionPercentage(),
        );
        
        debugPrint('\n💾 ACTUALIZANDO PERFIL:');
        debugPrint('👤 Username: ${updatedData.username}');
        debugPrint('📏 Altura: ${updatedData.height} PULGADAS');
        debugPrint('⚖️ Peso: ${updatedData.weight} LBS');
        debugPrint('📅 BirthDate: ${updatedData.birthDate}');
        debugPrint('👫 Gender: ${updatedData.gender}');
        debugPrint('🌐 Language: ${updatedData.language}');
        
        // LOGS DETALLADOS PARA DEPURACIÓN
        debugPrint('\n==================================================');
        debugPrint('🔍 DATOS ENVIADOS EN GUARDADO DE PERFIL - DETALLADO');
        debugPrint('==================================================');
        debugPrint('👤 ID: ${updatedData.id}');
        debugPrint('👤 Username: ${updatedData.username}');
        debugPrint('📧 Email: ${updatedData.email}');
        debugPrint('📏 Altura: ${updatedData.height} pulgadas (tipo: ${updatedData.height.runtimeType})');
        debugPrint('⚖️ Peso: ${updatedData.weight} libras (tipo: ${updatedData.weight.runtimeType})');
        debugPrint('📅 BirthDate: ${updatedData.birthDate} (tipo: ${updatedData.birthDate.runtimeType})');
        debugPrint('👫 Gender: ${updatedData.gender} (tipo: ${updatedData.gender.runtimeType})');
        debugPrint('🌐 Language: ${updatedData.language} (tipo: ${updatedData.language.runtimeType})');
        debugPrint('✅ isComplete: ${updatedData.isComplete}');
        debugPrint('📊 completionPercentage: ${updatedData.profileCompletionPercentage}%');
        
        // Convertir a JSON para verificar exactamente lo que se enviará
        final jsonData = updatedData.toJson();
        debugPrint('\n📦 DATOS JSON QUE SE ENVIARÁN AL BACKEND:');
        jsonData.forEach((key, value) {
          debugPrint('   $key: $value (tipo: ${value?.runtimeType})');
        });
        debugPrint('==================================================');
        
        // Llamar al servicio para actualizar (retorna UserProfileData o lanza excepción)
        final result = await _authService.updateProfile(
          token: token,
          updatedData: updatedData,
        );
        
        // Si llegamos aquí, el update fue exitoso
        if (mounted) {
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${localizations['settings']['profileForm']['profileUpdateSuccess']}'),
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
          final localizations = AppLocalizations.of(context)!;
          final errorMessage = _parseErrorMessage(e.toString(), localizations);
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
    final localizations = AppLocalizations.of(context)!;
    
    if (_usernameController.text.trim().isEmpty) {
      missingFields.add(localizations['settings']['user']);
    }
    // Height and weight can't be null anymore
    if (_birthDateController.text.trim().isEmpty) {
      missingFields.add(localizations['settings']['birthDay']);
    }
    if (_selectedGender.isEmpty) {
      missingFields.add(localizations['settings']['gender']);
    }
    
    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ ${localizations['settings']['profileForm']['pleaseComplete']} ${missingFields.join(", ")}'),
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
          final localizations = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('❌ ${localizations['settings']['profileForm']['validationErrors']}', 
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
  
  String _parseErrorMessage(String error, dynamic localizations) {
    // Extract readable message from error
    if (error.contains('altura') || error.contains('height')) {
      return localizations['settings']['profileForm']['heightRange'];
    }
    if (error.contains('peso') || error.contains('weight')) {
      return localizations['settings']['profileForm']['weightMin'];
    }
    return error;
  }

  bool _isProfileComplete() {
    return _usernameController.text.isNotEmpty &&
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
    return Material(
      color: Colors.transparent,
      child: Form(
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
              AppLocalizations.of(context)!['settings']['profileForm']['tapAvatarToChange'],
              style: TextStyle(color: Colors.white60, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            // Username field
            Text(AppLocalizations.of(context)!['settings']['user']),
            TextFormField(controller: _usernameController),

            
            // Height picker
            // IMPORTANTE: el valor de _height siempre se maneja en PULGADAS (ej: 67.0)
            HeightPicker(
              key: ValueKey('height_picker_${_selectedLanguage}_$_height'),
              initialValue: _height,
              isMetric: _selectedLanguage != 'en',
              onChanged: (value) {
                setState(() {
                  _height = value;
                  debugPrint('📏 Altura cambiada a: $value PULGADAS');
                });
              },
            ),
            
            // Weight picker
            // IMPORTANTE: el valor de _weight siempre se maneja en LIBRAS (ej: 150.0)
            WeightPicker(
              key: ValueKey('weight_picker_${_selectedLanguage}_$_weight'),
              initialValue: _weight,
              isMetric: _selectedLanguage != 'en',
              onChanged: (value) {
                setState(() {
                  _weight = value;
                  debugPrint('⚖️ Peso cambiado a: $value LIBRAS');
                });
              },
            ),

            Text(AppLocalizations.of(context)!['settings']['birthDay']),
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
                  helpText: AppLocalizations.of(context)!['settings']['profileForm']['birthDateHelper'],
                  errorFormatText: AppLocalizations.of(context)!['settings']['profileForm']['birthDateInvalid'],
                );
                if (date != null) {
                  _birthDateController.text =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!['settings']['profileForm']['birthDateRequired'];
                }
                
                // Validate date format
                try {
                  final parts = value.split('-');
                  if (parts.length != 3) {
                    return AppLocalizations.of(context)!['settings']['profileForm']['birthDateInvalid'];
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
                    return AppLocalizations.of(context)!['settings']['minAge'];
                  }
                  
                  return null;
                } catch (e) {
                  return AppLocalizations.of(context)!['settings']['profileForm']['birthDateInvalid'];
                }
              },
            ),

            Text(AppLocalizations.of(context)!['settings']['gender']),
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
                  return AppLocalizations.of(context)!['settings']['profileForm']['genderRequired'];
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
                  : Text(
                      AppLocalizations.of(context)!['common']['save'],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            
            const SizedBox(height: 20),
            
            // Card del plan por encima del selector de idioma
            ListenableBuilder(
              listenable: _subscriptionProvider,
              builder: (context, _) {
                final plan = _subscriptionProvider.currentPlan;
                final isLoading = _subscriptionProvider.isLoading;
                final error = _subscriptionProvider.error;
                
                // Si no tenemos datos del plan y no está cargando actualmente
                // solicitamos una actualización
                if (plan == null && !isLoading && mounted) {
                  debugPrint('🔄 Card de Plan: No hay datos de plan, solicitando actualización...');
                  Future.microtask(() => _loadPlan());
                }
                
                if (isLoading) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2C3B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!['plans']['myPlan'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFEDE954),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!['plans']['loadingPlanInfo'],
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                }
                
                // Cuando no hay plan disponible
                if (plan == null) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2C3B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!['plans']['myPlan'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!['plans']['notActive'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppLocalizations.of(context)!['plans']['noPlanMessage'],
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Usar pushReplacement para evitar problemas con el navigator lock
                              try {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PlansScreen(),
                                  ),
                                ).catchError((error) {
                                  debugPrint('Error al navegar a PlansScreen: $error');
                                });
                              } catch (e) {
                                debugPrint('Error al intentar navegar: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEDE954),
                              foregroundColor: Colors.black,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!['plans']['viewPlans'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Plan gratuito o con información incompleta
                if (plan.plan_details == null) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE954),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!['plans']['myPlan'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!['plans']['active'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!['plans']['planFree'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!['plans']['basicPlanDescription'],
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute(
                                  builder: (context) => PlansScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(AppLocalizations.of(context)!['plans']['viewPremiumPlans']),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Plan activo con datos completos
                final daysRemaining = plan.daysRemaining ?? 0;
                final planTitle = plan.plan_details?.title ?? 'Plan Desconocido';
                final expirationDate = plan.currentPeriodEnd != null 
                  ? _formatDate(plan.currentPeriodEnd!) 
                  : 'No disponible';
                
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE954),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!['plans']['myPlan'] ?? 'Mi Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!['plans']['active'] ?? 'ACTIVO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        planTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: Colors.black.withOpacity(0.7)),
                          SizedBox(width: 6),
                          Text(
                            '${AppLocalizations.of(context)!['plans']['expires']}: $expirationDate',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timelapse, size: 16, color: Colors.black.withOpacity(0.7)),
                          SizedBox(width: 6),
                          Text(
                            '${AppLocalizations.of(context)!['plans']['daysRemaining']}: $daysRemaining',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                builder: (context) => const PlansScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(AppLocalizations.of(context)!['plans']['changePlan']),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Selector de idioma
            LanguageSelector(),
          ],
        ),
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
    final localizations = AppLocalizations.of(context)!;
    switch (gender) {
      case 'male':
        return localizations['gender']['male'];
      case 'female':
        return localizations['gender']['female'];
      case 'other':
        return localizations['gender']['other'];
      default:
        return gender;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
