import 'package:flutter/material.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/themes/app_theme.dart';

void main() {
  runApp(const ServiZoneApp()); // 👈 Cambiado de MyApp a ServiZoneApp
}

class ServiZoneApp extends StatelessWidget { // 👈 Clase renombrada
  const ServiZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ServiZone',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.adminDashboard, // Antes era AppRoutes.splash
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}