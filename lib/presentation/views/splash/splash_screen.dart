import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Simular tiempo de carga
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      // Obtener el rol guardado
      final role = prefs.getString('user_role') ?? '';
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        case 'client':
          Navigator.pushReplacementNamed(context, AppRoutes.clientHome);
          break;
        case 'provider':
          Navigator.pushReplacementNamed(context, AppRoutes.providerHome);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      // No hay sesión, ir al login
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.handyman,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Servi', style: TextStyle(color: Colors.white)),
                  TextSpan(text: 'Zone', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}


