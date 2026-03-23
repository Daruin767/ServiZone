import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/provider/services/provider_services_screen.dart';
import 'package:servizone_app/presentation/views/provider/provider_bookings_screen.dart';

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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCreateServiceDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCategory;
    String? selectedSubcategory;
    String? selectedType;
    bool isActive = true;

    const categoriesList = ['Hogar', 'Ciclismo', 'Cuidado Personal', 'Mascotas', 'Otros'];
    const subcategoriesMap = {
      'Hogar': ['Plomería', 'Electricidad', 'Limpieza', 'Jardinería'],
      'Ciclismo': ['Mantenimiento', 'Reparación', 'Venta de Accesorios'],
      'Cuidado Personal': ['Barbería', 'Manicura', 'Maquillaje'],
      'Mascotas': ['Paseo', 'Entrenamiento', 'Baño'],
      'Otros': ['Varios'],
    };
    const typesList = ['Mantenimiento', 'Instalación', 'Reparación', 'Consultoría', 'Otros'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crear Nuevo Servicio', style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del servicio', prefixIcon: Icon(Icons.build_rounded)),
                    validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción', prefixIcon: Icon(Icons.description_rounded)),
                    maxLines: 3,
                    validator: (v) => v == null || v.isEmpty ? 'La descripción es obligatoria' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category_rounded)),
                    items: categoriesList.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setModalState(() {
                      selectedCategory = v;
                      selectedSubcategory = null;
                    }),
                    validator: (v) => v == null ? 'Selecciona una categoría' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subcategoría', prefixIcon: Icon(Icons.list_rounded)),
                    items: (subcategoriesMap[selectedCategory] ?? <String>[])
                        .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedSubcategory = v),
                    validator: (v) => v == null ? 'Selecciona una subcategoría' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de servicio', prefixIcon: Icon(Icons.merge_type_rounded)),
                    items: typesList.map((t) => DropdownMenuItem<String>(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setModalState(() => selectedType = v),
                    validator: (v) => v == null ? 'Selecciona un tipo' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Estado del servicio (Activo)'),
                    value: isActive,
                    onChanged: (v) => setModalState(() => isActive = v),
                    activeThumbColor: primaryBlue,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            services.add({
                              'name': nameController.text,
                              'price': 0, // Precio por defecto o añadir campo
                              'status': isActive ? 'Activo' : 'Inactivo',
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Servicio creado correctamente'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                          );
                        }
                      },
                      child: const Text('Crear Servicio'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                'Bienvenido, @$_userName!',
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
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
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    String statusText = booking['status'] ?? 'Pendiente';

    switch (statusText) {
      case 'Confirmada':
        statusColor = Colors.blue;
        break;
      case 'Pendiente':
        statusColor = Colors.orange;
        break;
      case 'Cancelada':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
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
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_rounded, size: 20, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente: ${booking['client']}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking['date']} - ${booking['time']}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
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
        currentIndex: 0,
        onTap: (index) async {
          HapticFeedback.lightImpact();
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderServicesScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderBookingsScreen()),
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
        selectedItemColor: primaryBlue,
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
}
