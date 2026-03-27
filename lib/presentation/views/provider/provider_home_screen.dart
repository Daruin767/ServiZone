import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:servizone_app/core/locator.dart';
import 'package:servizone_app/data/providers/auth_service.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/provider/services/provider_services_screen.dart';
import 'package:servizone_app/presentation/views/provider/provider_bookings_screen.dart';
import 'package:servizone_app/presentation/widgets/shared/provider_bottom_nav.dart';
import 'package:servizone_app/presentation/widgets/provider/create_service_bottom_sheet.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  String _userName = 'Usuario';
  int _currentIndex = 0; // 0: Inicio

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final data = locator<AuthService>().currentUserProfile;
    if (data != null && mounted) {
      setState(() {
        _userName = data['nombre'] ?? data['Nombre'] ?? 'Usuario Proveedor';
      });
    }
  }

  Future<void> _logout() async {
    await locator<AuthService>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  final List<Map<String, dynamic>> services = [
    {
      'name': 'Servicio de ejemplo 1',
      'price': 45000,
      'status': 'Activo',
    },
    {
      'name': 'Servicio de ejemplo 1',
      'price': 45000,
      'status': 'Inactivo',
    },
    {
      'name': 'Servicio de ejemplo 1',
      'price': 45000,
      'status': 'Activo',
    },
  ];

  void _showCreateServiceDialog() {
    CreateServiceBottomSheet.show(context, onServiceCreated: (newService) {
      if (mounted) {
        setState(() {
          services.add(newService);
        });
      }
    });
  }

  final List<Map<String, dynamic>> bookings = const [
    {
      'client': 'Ana García',
      'date': '15 marzo 2026',
      'time': '10:30',
      'status': 'Confirmada',
    },
    {
      'client': 'Carlos Ruiz',
      'date': '16 marzo 2026',
      'time': '11:00',
      'status': 'Pendiente',
    },
    {
      'client': 'María López',
      'date': '17 marzo 2026',
      'time': '14:45',
      'status': 'Cancelada',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Contenedor de bienvenida: fondo blanco, ocupa todo el ancho
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Text(
                'Bienvenido, $_userName!',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: lightGray, thickness: 1),
                  const SizedBox(height: 20),

                  // Tarjeta de métricas
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMetric(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          value: '4.8',
                          label: 'Calificación promedio',
                        ),
                        _buildVerticalDivider(),
                        _buildMetric(
                          icon: Icons.calendar_today_rounded,
                          iconColor: const Color(0xFF1976D2),
                          value: '12',
                          label: 'Reservas del mes',
                        ),
                        _buildVerticalDivider(),
                        _buildMetric(
                          icon: Icons.attach_money_rounded,
                          iconColor: const Color(0xFF2E7D32),
                          value: '\$200,000',
                          label: 'Ingresos',
                        ),
                        _buildVerticalDivider(),
                        _buildMetric(
                          icon: Icons.build_rounded,
                          iconColor: const Color(0xFF1976D2),
                          value: '3',
                          label: 'Servicios activos',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón Crear nuevo servicio
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateServiceDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Crear Nuevo Servicio',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Tus servicios'),
                  const SizedBox(height: 12),

                  ...services.map((service) => _buildServiceCard(service)),

                  const SizedBox(height: 8),
                  Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProviderServicesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Ver todos mis servicios >',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: textGray,
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Proximas reservas'),
                  const SizedBox(height: 12),

                  ...bookings.map((booking) => _buildBookingCard(booking)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 0),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16, // Reducir un poco para evitar desbordamiento
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 9, // Reducir un poco
              color: textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: lightGray,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final bool isActive = service['status'] == 'Activo';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.build_rounded, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textGray),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${NumberFormat('#,###').format(service['price'])}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryBlue),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? successGreen : errorRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              service['status'],
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    String statusText = booking['status'] ?? 'Pendiente';
    Color statusColor = switch (statusText) {
      'Confirmada' => successGreen,
      'Pendiente' => warningOrange,
      'Cancelada' => errorRed,
      _ => warningOrange,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.calendar_today_rounded, size: 20, color: statusColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente: ${booking['client']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textGray),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking['date']} - ${booking['time']}',
                  style: const TextStyle(fontSize: 12, color: textGray),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

}


