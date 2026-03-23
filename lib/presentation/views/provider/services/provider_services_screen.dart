import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/provider/provider_bookings_screen.dart';

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

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  void _showReasonDialog(int index) {
    final reasonController = TextEditingController();
    bool isActive = services[index]['status'] == 'Activo';
    String action = isActive ? 'desactivar' : 'activar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${isActive ? 'Desactivar' : 'Activar'} servicio', style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Por qué deseas $action este servicio?', style: Theme.of(context).textTheme.bodyMedium),
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
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
    await Future.delayed(const Duration(milliseconds: 800));
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      setState(() {
        services[index]['status'] =
            services[index]['status'] == 'Activo' ? 'Inactivo' : 'Activo';
        _showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } else {
      setState(() {
        _showError = true;
        _errorMessage = 'No se pudo cambiar el estado';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
    }
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
                              'price': 0,
                              'status': isActive ? 'Activo' : 'Inactivo',
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Servicio creado correctamente'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          Column(
            children: [
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
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    _buildSectionTitle('Tus servicios'),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showCreateServiceDialog,
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
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.build_rounded,
                              color: Color(0xFF1976D2),
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
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF4CAF50) : Colors.red,
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
                              IconButton(
                                icon: Icon(
                                  isActive ? Icons.toggle_on : Icons.toggle_off,
                                  color: isActive ? Colors.green : Colors.grey,
                                  size: 32,
                                ),
                                onPressed: () => _showReasonDialog(index), // Permitir activar/desactivar normalmente
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              _buildBottomNavBar(),
            ],
          ),

          if (_showSuccess)
            _buildModal(
              icon: Icons.check_circle,
              color: Colors.green,
              message: 'Estado actualizado',
            ),
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
        currentIndex: 1,
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
              );
              break;
            case 1:
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
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
