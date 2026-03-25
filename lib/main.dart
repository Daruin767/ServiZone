import 'package:flutter/material.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/themes/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:servizone_app/core/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator(); // Inicializar inyección de dependencias
  runApp(const ServiZoneApp());
}

class ServiZoneApp extends StatelessWidget {
  const ServiZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiZone',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
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
  }
}
