import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/client/home_client_screen.dart';
import 'package:servizone_app/presentation/views/client/services/service_list_screen.dart';

import 'package:servizone_app/core/routes/app_routes.dart';

class SubcategoryScreen extends StatefulWidget {
  final String categoryName;
  final bool isGuest;

  const SubcategoryScreen({
    super.key,
    required this.categoryName,
    this.isGuest = false,
  });

  @override
  State<SubcategoryScreen> createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, List<Map<String, dynamic>>> _categorySubcategories = {
    'Hogar': [
      {'name': 'Plomería', 'icon': Icons.plumbing, 'color': const Color(0xFF4FA3D1)},
      {'name': 'Electricidad', 'icon': Icons.electrical_services, 'color': const Color(0xFFF5A623)},
      {'name': 'Carpintería', 'icon': Icons.handyman, 'color': const Color(0xFF8B5A2B)},
      {'name': 'Pintura', 'icon': Icons.format_paint, 'color': const Color(0xFFE91E63)},
      {'name': 'Jardinería', 'icon': Icons.yard, 'color': const Color(0xFF2E7D32)},
    ],
    'Servi Favor': [
      {'name': 'Clases particulares', 'icon': Icons.school, 'color': Colors.purple},
      {'name': 'Cuidado de mascotas', 'icon': Icons.pets, 'color': Colors.orange},
      {'name': 'Mudanzas', 'icon': Icons.local_shipping, 'color': Colors.brown},
      {'name': 'Ayuda con mudanzas', 'icon': Icons.move_to_inbox, 'color': Colors.teal},
    ],
    'Ciclismo': [
      {'name': 'Reparación de bicicletas', 'icon': Icons.build, 'color': const Color(0xFFE65100)},
      {'name': 'Venta de accesorios', 'icon': Icons.shopping_cart, 'color': Colors.blueGrey},
      {'name': 'Clases de ciclismo', 'icon': Icons.directions_bike, 'color': Colors.green},
    ],
    'Cuidado': [
      {'name': 'Cuidado de niños', 'icon': Icons.child_care, 'color': Colors.pink},
      {'name': 'Cuidado de adultos mayores', 'icon': Icons.elderly, 'color': Colors.deepPurple},
    ],
    'Cuidado Personal': [
      {'name': 'Peluquería', 'icon': Icons.content_cut, 'color': Colors.deepOrange},
      {'name': 'Manicura y pedicura', 'icon': Icons.face, 'color': Colors.pinkAccent},
      {'name': 'Masajes', 'icon': Icons.spa, 'color': primaryDarkBlue},
    ],
    'Mascotas': [
      {'name': 'Paseo de perros', 'icon': Icons.pets, 'color': Colors.brown},
      {'name': 'Veterinario a domicilio', 'icon': Icons.local_hospital, 'color': Colors.red},
      {'name': 'Guardería para mascotas', 'icon': Icons.house, 'color': Colors.amber},
    ],
  };

  List<Map<String, dynamic>> get _subcategories {
    final list = _categorySubcategories[widget.categoryName] ?? [];
    if (_searchQuery.isEmpty) return list;
    return list.where((s) => s['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToHomeWithIndex(int index) {
    if (widget.isGuest) {
      // Si es invitado, no puede navegar a otras pestañas que requieran auth
      if (index == 2) {
        Navigator.pop(context);
      } else {
        _showLoginRequiredDialog();
      }
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeClientScreen(initialIndex: index)),
      (route) => false,
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Acceso restringido'),
        content: const Text('Para acceder a esta sección debes iniciar sesión o registrarte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
        // Sin leading
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: cardShadow, blurRadius: 8)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar subcategoría...',
                  hintStyle: TextStyle(color: textGray),
                  prefixIcon: Icon(Icons.search_rounded, color: textGray),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: textGray),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: _subcategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 60, color: textGray),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron subcategorías',
                          style: TextStyle(color: textGray, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _subcategories.length,
                    itemBuilder: (context, index) {
                      final sub = _subcategories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: cardShadow, blurRadius: 8)],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceListScreen(
                                    categoryName: widget.categoryName,
                                    subcategoryName: sub['name'],
                                    isGuest: widget.isGuest,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: sub['color'].withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(sub['icon'], color: sub['color'], size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      sub['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: darkGray,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, color: textGray, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (index == 2) return;
          _navigateToHomeWithIndex(index);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textGray,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: "Reservas"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: "Solicitudes"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Servicios"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Perfil"),
        ],
      ),
    );
  }
}


