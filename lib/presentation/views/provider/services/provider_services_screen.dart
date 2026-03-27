import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/locator.dart';
import 'package:servizone_app/data/providers/auth_service.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/provider/provider_bookings_screen.dart';
import 'package:servizone_app/presentation/widgets/shared/provider_bottom_nav.dart';
import 'package:servizone_app/presentation/widgets/provider/create_service_bottom_sheet.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  String _userName = 'Usuario';
  String? _statusFilter;

  List<Map<String, dynamic>> services = [
    {
      'name': 'Servicio de ejemplo 1',
      'price': 45000,
      'status': 'Activo',
    },
    {
      'name': 'Servicio de ejemplo 2',
      'price': 45000,
      'status': 'Inactivo',
    },
    {
      'name': 'Servicio de ejemplo 3',
      'price': 45000,
      'status': 'Activo',
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_statusFilter == null) return services;
    return services.where((s) => s['status'] == _statusFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() {
    final data = locator<AuthService>().currentUserProfile;
    if (data != null && mounted) {
      setState(() {
        _userName = "${data['nombre'] ?? data['Nombre'] ?? ''} ${data['apellido'] ?? data['Apellido'] ?? ''}".trim();
        if (_userName.isEmpty) {
          _userName = 'Usuario Proveedor';
        }
      });
    }
  }

  Future<void> _logout() async {
    await locator<AuthService>().logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar Servicios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textGray)),
            const SizedBox(height: 20),
            _buildFilterOption('Todos', _statusFilter == null, () => setState(() => _statusFilter = null)),
            _buildFilterOption('Activos', _statusFilter == 'Activo', () => setState(() => _statusFilter = 'Activo')),
            _buildFilterOption('Inactivos', _statusFilter == 'Inactivo', () => setState(() => _statusFilter = 'Inactivo')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? primaryBlue : textGray, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: primaryBlue) : null,
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: successGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(_userName),
                    style: const TextStyle(
                      color: successGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          '$_userName',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textGray,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: textGray),
            onPressed: _showFilterMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Text(
                  'Tus servicios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textGray),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreateServiceModal,
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
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                final isActive = service['status'] == 'Activo';
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
                              '\$${service['price']}',
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
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ProviderBottomNav(currentIndex: 1),
    );
  }

  void _showCreateServiceModal() {
    CreateServiceBottomSheet.show(context, onServiceCreated: (newService) {
      if (mounted) {
        setState(() {
          services.insert(0, newService);
        });
      }
    });
  }
}
