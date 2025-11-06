import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:genius_hormo/providers/locale_provider.dart';
import 'package:genius_hormo/theme/theme.dart';
import 'package:genius_hormo/views/auth/welcome.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   title: 'GeniusHormo',
    //   theme: theme,

    //   home: WelcomeScreen(),
    //   routes: AppRoutes.routes,
    // );

    return ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'GeniusHormo',
            theme: theme,
            routes: AppRoutes.routes,

            locale: localeProvider.locale,
            localizationsDelegates:  [
              AppLocalizations.delegate,
              // GlobalMaterialLocalizations.delegate,
              // GlobalWidgetsLocalizations.delegate,
              // GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('es', '')],
            home: WelcomeScreen(),
          );
        },
      ),
    );
  }
}
