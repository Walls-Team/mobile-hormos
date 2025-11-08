import 'package:genius_hormo/core/api/api_client.dart' show ApiClient;
import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_service.dart';
import 'package:genius_hormo/core/navigation/navigation_service.dart';
import 'package:genius_hormo/features/auth/services/auth_provider.dart';
import 'package:genius_hormo/providers/lang_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<GeniusHormoDeepLinkService>(
    () => GeniusHormoDeepLinkService(),
  );
  
  getIt.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );

  // ✅ Registrar LanguageService
  getIt.registerLazySingleton<LanguageService>(
    () => LanguageService(),
  );


    getIt.registerSingleton<ApiClient>(
    ApiClient(
      baseUrl: 'http://localhost:3000', // Cambia por tu URL
      // baseUrl: 'http://10.0.2.2:3000', // Para emulador Android
      // baseUrl: 'http://127.0.0.1:3000', // Para iOS simulator
    ),

    
  );

  getIt.registerLazySingleton<AuthService>(() => AuthService());
}