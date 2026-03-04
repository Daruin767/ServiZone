import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const _ServicesTab(),
    const _BookingsTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mediumGray,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}

// -------------------- TABS DEL PROVEEDOR --------------------

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Panel de Proveedor'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de resumen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.business_center, color: primaryBlue, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '¡Bienvenido, Proveedor!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tienes 12 servicios activos',
                          style: TextStyle(color: mediumGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tus servicios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) => _buildServiceCard(index)),
            const SizedBox(height: 24),
            const Text(
              'Próximas reservas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray),
            ),
            const SizedBox(height: 16),
            ...List.generate(2, (index) => _buildBookingCard(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.build_rounded, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servicio de ejemplo ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: darkGray),
                ),
                const SizedBox(height: 4),
                const Text('\$45.000', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Activo', style: TextStyle(color: Colors.green, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: const Icon(Icons.person, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cliente: Ana García', style: TextStyle(fontWeight: FontWeight.bold, color: darkGray)),
                const SizedBox(height: 4),
                Text('15 Mar 2026 • 10:30', style: TextStyle(color: mediumGray, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Confirmada', style: TextStyle(color: Colors.blue, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Mis Servicios'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Aquí podrás gestionar tus servicios',
          style: TextStyle(color: mediumGray),
        ),
      ),
    );
  }
}

class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Reservas'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Aquí verás las reservas de tus clientes',
          style: TextStyle(color: mediumGray),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business_center, size: 80, color: primaryBlue),
            const SizedBox(height: 20),
            const Text('Proveedor Demo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('proveedor@servizone.com', style: TextStyle(color: mediumGray)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}