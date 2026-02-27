import 'package:flutter/material.dart';
import 'package:servizone_app/presentation/views/auth/login_screen.dart';
import 'package:servizone_app/presentation/views/auth/register_screen.dart';
import 'package:servizone_app/presentation/views/client/home_client_screen.dart';
import 'package:servizone_app/presentation/views/admin/dashboard_screen.dart';
import 'package:servizone_app/presentation/views/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String clientHome = '/client/home';
  static const String adminDashboard = '/admin/dashboard';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case clientHome:
        return MaterialPageRoute(builder: (_) => const HomeClientScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}