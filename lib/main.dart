import 'package:flutter/material.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/themes/app_theme.dart';

void main() {
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
      initialRoute: AppRoutes.splash, // 👈 Cambiado de adminDashboard a splash
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}