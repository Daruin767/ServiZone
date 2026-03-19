import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/provider/services/provider_services_screen.dart';

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

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name');
    if (name != null && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  final List<Map<String, dynamic>> services = List.generate(3, (index) => {
        'name': 'Servicio de ejemplo 1',
        'price': 45000,
        'status': 'Activo',
      });

  final List<Map<String, dynamic>> bookings = [
    {
      'client': 'Ana garcia',
      'date': '15 marzo 2026',
      'time': '10:30',
      'status': 'Confirmada',
    },
    {
      'client': 'Ana garcia',
      'date': '15 marzo 2026',
      'time': '11:00',
      'status': 'Pendiente',
    },
    {
      'client': 'Ana garcia',
      'date': '15 marzo 2026',
      'time': '10:30',
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
                'Bienvenido, @$_userName!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
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
                          color: Colors.black.withOpacity(0.05),
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
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Crear nuevo servicio',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Tus servicios'),
                  const SizedBox(height: 12),

                  ...services.map((service) => _buildServiceCard(service)).toList(),

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
                        color: mediumGray,
                      ),
                    ),
                  ),
                ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Proximas reservas'),
                  const SizedBox(height: 12),

                  ...bookings.map((booking) => _buildBookingCard(booking)).toList(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              color: mediumGray,
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
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.build_rounded,
              color: const Color(0xFF1976D2),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${service['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    Color statusTextColor;
    Color circleColor;
    String statusText = booking['status'];

    switch (statusText) {
      case 'Confirmada':
        statusColor = const Color(0xFF64B5F6);
        statusTextColor = const Color(0xFF0D47A1);
        circleColor = const Color(0xFFDCE775);
        break;
      case 'Pendiente':
        statusColor = const Color(0xFFFFF176);
        statusTextColor = const Color(0xFFF57F17);
        circleColor = const Color(0xFFDCE775);
        break;
      case 'Cancelada':
        statusColor = const Color(0xFFE57373);
        statusTextColor = Colors.white;
        circleColor = const Color(0xFFDCE775);
        break;
      default:
        statusColor = Colors.grey;
        statusTextColor = Colors.white;
        circleColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente: ${booking['client']}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking['date']} - ${booking['time']}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          HapticFeedback.lightImpact();
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              // Ya estamos en inicio
              break;
            case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProviderServicesScreen()),
            );
            break;
            case 2:
              // Reservas (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sección de reservas en desarrollo'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              break;
            case 3:
              // Cuenta: navegar a ProviderProfileScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProviderProfileScreen(
                    onLogout: _logout,
                  ),
                ),
              );
              break;
          }
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: mediumGray,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}