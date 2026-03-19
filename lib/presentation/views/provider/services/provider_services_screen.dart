import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  String _userName = 'Usuario';
  int _currentIndex = 1; // Servicios activo

  List<Map<String, dynamic>> services = [
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

  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = 'Error al cambiar estado';

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

  void _showReasonDialog(int index) {
    final reasonController = TextEditingController();
    bool isActive = services[index]['status'] == 'Activo';
    String action = isActive ? 'desactivar' : 'activar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${isActive ? 'Desactivar' : 'Activar'} servicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Por qué deseas $action este servicio?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe el motivo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'), // Este es el botón "Volver"
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // cerrar diálogo
              await _toggleServiceStatus(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleServiceStatus(int index) async {
    // Simular proceso
    await Future.delayed(const Duration(milliseconds: 800));

    // Simular éxito/error aleatorio
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      // Éxito: cambiar estado
      setState(() {
        services[index]['status'] =
            services[index]['status'] == 'Activo' ? 'Inactivo' : 'Activo';
        _showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } else {
      // Error
      setState(() {
        _showError = true;
        _errorMessage = 'No se pudo cambiar el estado';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          Column(
            children: [
              // Header con avatar y nombre (sin botón volver)
              Container(
                height: 80,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(_userName),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '@$_userName',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    // Sin botón volver
                  ],
                ),
              ),

              // Título de la pantalla
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    const Text(
                      'Tus servicios',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Crear nuevo servicio (próximamente)'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nuevo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Lista de servicios
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isActive = service['status'] == 'Activo';
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
                          // Icono
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
                          // Información
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
                          // Badge de estado y botón de cambio
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  service['status'],
                                  style: const TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Botón para activar/desactivar (icono de interruptor)
                              IconButton(
                                icon: Icon(
                                  isActive ? Icons.toggle_on : Icons.toggle_off,
                                  color: isActive ? Colors.green : Colors.grey,
                                  size: 32,
                                ),
                                onPressed: () => _showReasonDialog(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Barra de navegación inferior
              _buildBottomNavBar(),
              // SIN barra de gestos negra
            ],
          ),

          // Modal de éxito
          if (_showSuccess)
            _buildModal(
              icon: Icons.check_circle,
              color: Colors.green,
              message: 'Estado actualizado',
            ),

          // Modal de error
          if (_showError)
            _buildModal(
              icon: Icons.cancel,
              color: Colors.red,
              message: _errorMessage,
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
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
          if (index == _currentIndex) return; // ya estamos en esa pantalla
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
              );
              break;
            case 1:
              // Ya estamos en servicios, no hacer nada
              break;
            case 2:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sección de reservas en desarrollo'), behavior: SnackBarBehavior.floating),
              );
              break;
            case 3:
              Navigator.pushReplacement(
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
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Servicios'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Cuenta'),
        ],
      ),
    );
  }

  Widget _buildModal({required IconData icon, required Color color, required String message}) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 70, color: color),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}