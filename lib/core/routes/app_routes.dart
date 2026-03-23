import 'package:flutter/material.dart';
import 'package:servizone_app/presentation/views/auth/login_screen.dart';
import 'package:servizone_app/presentation/views/auth/register_screen.dart';
import 'package:servizone_app/presentation/views/client/home_client_screen.dart';
import 'package:servizone_app/presentation/views/admin/dashboard_screen.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/guest/guest_home_screen.dart';
import 'package:servizone_app/presentation/views/splash/splash_screen.dart';

import 'package:servizone_app/presentation/views/auth/forgot_password_screen.dart';
import 'package:servizone_app/presentation/views/provider/provider_request_screen.dart';
import 'package:servizone_app/presentation/views/admin/category_management_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String clientHome = '/client/home';
  static const String providerHome = '/provider/home';
  static const String guestHome = '/guest/home';
  static const String adminDashboard = '/admin/dashboard';
  static const String reservas = '/reservas';
  static const String account = '/account';
  static const String providerProfile = '/provider/profile';
  static const String providerEditProfile = '/provider/edit-profile';
  static const String providerChangePassword = '/provider/change-password';
  static const String clientApplication = '/provider/client-application';
  

  static const String forgotPassword = '/auth/forgot-password';
  static const String providerRequest = '/provider/request';
  static const String categoryManagement = '/admin/categories';
  static const String subcategoryManagement = '/admin/subcategories';
  static const String serviceTypeManagement = '/admin/service-types';

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
      case providerHome:
        return MaterialPageRoute(builder: (_) => const ProviderHomeScreen());
      case guestHome:
        return MaterialPageRoute(builder: (_) => const GuestHomeScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case providerRequest:
        return MaterialPageRoute(builder: (_) => const ProviderRequestScreen());
      case categoryManagement:
        return MaterialPageRoute(builder: (_) => const CategoryManagementScreen());
      case subcategoryManagement:
        // TODO: Implementar SubcategoryManagementScreen
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Subcategory Management'))));
      case serviceTypeManagement:
        // TODO: Implementar ServiceTypeManagementScreen
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Service Type Management'))));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }
}
