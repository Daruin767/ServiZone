import 'package:flutter/material.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/themes/app_theme.dart';
import 'package:servizone_app/core/themes/theme_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

// Global provider for simplicity in this task context
final ThemeProvider themeProvider = ThemeProvider();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServiZoneApp());
}

class ServiZoneApp extends StatelessWidget {
  const ServiZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ServiZone',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          // Transición suave entre temas
          builder: (context, child) {
            return AnimatedTheme(
              data: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
              duration: const Duration(milliseconds: 200),
              child: child!,
            );
          },
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
          ],
        );
      },
    );
  }
}
