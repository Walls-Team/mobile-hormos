import 'package:genius_hormo/core/deep_link/genius_hormo_deep_link_service.dart';
import 'package:genius_hormo/core/navigation/navigation_service.dart';
import 'package:genius_hormo/features/auth/services/auth_service.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/features/dashboard/services/dashboard_service.dart';
import 'package:genius_hormo/features/setup/services/setup_status_service.dart';
import 'package:genius_hormo/features/spike/services/spike_providers.dart';
import 'package:genius_hormo/features/stats/service/stats_service.dart';
import 'package:genius_hormo/providers/lang_service.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<GeniusHormoDeepLinkService>(
    () => GeniusHormoDeepLinkService(),
  );

  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  // ✅ Registrar LanguageService
  getIt.registerLazySingleton<LanguageService>(() => LanguageService());

  // getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<UserStorageService>(() => UserStorageService());

  getIt.registerLazySingleton<SpikeApiService>(
    () => SpikeApiService(),
    // () => SpikeApiService(getIt<UserStorageService>()),
  );

  getIt.registerLazySingleton<SetupStatusService>(() => SetupStatusService());
  getIt.registerLazySingleton<DashBoardService>(() => DashBoardService());
  getIt.registerLazySingleton<StatsService>(() => StatsService());
}
