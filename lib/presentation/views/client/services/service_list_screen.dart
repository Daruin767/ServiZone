import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';

class ServiceListScreen extends StatefulWidget {
  final String categoryName;
  final String subcategoryName;

  const ServiceListScreen({
    super.key,
    required this.categoryName,
    required this.subcategoryName,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSort = 'Calificación';
  bool _sortAscending = false;
  final Set<String> _selectedTypes = {};

  // Estados para los modales de éxito/error
  bool _showSuccess = false;
  bool _showError = false;
  String _errorMessage = 'Error al reservar';

  final Map<String, List<Map<String, dynamic>>> _servicesBySubcategory = {
    'Plomería': [
      {
        'name': 'Reparación de fugas',
        'professional': 'Carlos Ramírez',
        'description': 'Reparación rápida de fugas en tuberías, lavamanos o conexiones domésticas.',
        'price': 45000,
        'rating': 4.5,
        'type': 'Reparación',
        'iconColor': const Color(0xFF4FA3D1),
        'icon': Icons.plumbing,
      },
      {
        'name': 'Instalación de grifería',
        'professional': 'Luis Mendoza',
        'description': 'Instalación profesional de grifos, duchas y accesorios de baño.',
        'price': 60000,
        'rating': 3.8,
        'type': 'Instalación',
        'iconColor': const Color(0xFF58C58F),
        'icon': Icons.build,
      },
      {
        'name': 'Destape de tuberías',
        'professional': 'Andrés López',
        'description': 'Servicio rápido para desatascar drenajes y tuberías del hogar.',
        'price': 50000,
        'rating': 4.2,
        'type': 'Emergencia',
        'iconColor': const Color(0xFFF5A623),
        'icon': Icons.cleaning_services,
      },
      {
        'name': 'Mantenimiento de cañerías',
        'professional': 'María González',
        'description': 'Revisión y mantenimiento preventivo de todo el sistema hidráulico.',
        'price': 35000,
        'rating': 4.7,
        'type': 'Mantenimiento',
        'iconColor': Colors.blue,
        'icon': Icons.water_drop,
      },
      {
        'name': 'Limpieza de desagües',
        'professional': 'Pedro Sánchez',
        'description': 'Limpieza profunda de desagües y eliminación de malos olores.',
        'price': 40000,
        'rating': 4.0,
        'type': 'Limpieza',
        'iconColor': Colors.teal,
        'icon': Icons.clean_hands,
      },
    ],
    'Electricidad': [
      {
        'name': 'Instalación eléctrica',
        'professional': 'Juan Pérez',
        'description': 'Instalación de puntos eléctricos, tableros y circuitos.',
        'price': 80000,
        'rating': 4.8,
        'type': 'Instalación',
        'iconColor': const Color(0xFFF5A623),
        'icon': Icons.electrical_services,
      },
      {
        'name': 'Reparación de cortocircuitos',
        'professional': 'Ana Gómez',
        'description': 'Diagnóstico y reparación de fallas eléctricas.',
        'price': 55000,
        'rating': 4.3,
        'type': 'Reparación',
        'iconColor': Colors.orange,
        'icon': Icons.build,
      },
    ],
    'Carpintería': [
      {
        'name': 'Fabricación de muebles',
        'professional': 'Roberto Sánchez',
        'description': 'Diseño y construcción de muebles a medida.',
        'price': 120000,
        'rating': 4.9,
        'type': 'Mantenimiento',
        'iconColor': const Color(0xFF8B5A2B),
        'icon': Icons.handyman,
      },
    ],
  };

  List<Map<String, dynamic>> get _allServices {
    return _servicesBySubcategory[widget.subcategoryName] ?? [];
  }

  List<String> get _availableTypes {
    return _allServices.map((s) => s['type'] as String).toSet().toList();
  }

  List<Map<String, dynamic>> get _filteredServices {
    var filtered = _allServices.where((s) {
      return s['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s['professional'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (_selectedTypes.isNotEmpty) {
      filtered = filtered.where((s) => _selectedTypes.contains(s['type'])).toList();
    }

    if (_selectedSort == 'Calificación') {
      filtered.sort((a, b) => _sortAscending
          ? a['rating'].compareTo(b['rating'])
          : b['rating'].compareTo(a['rating']));
    } else {
      filtered.sort((a, b) => _sortAscending
          ? a['price'].compareTo(b['price'])
          : b['price'].compareTo(a['price']));
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBookingDialog(Map<String, dynamic> service) {
    // Lista de reseñas de ejemplo
    final List<Map<String, String>> reviews = [
      {
        'name': 'Marlon Paez',
        'comment': 'Excelente corte, muy profesional',
      },
      {
        'name': 'Felipe Mazo',
        'comment': 'Me encanta lo que hace con mi cabello, es mi peluquero favorito, sabe lo que necesito',
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: Column(
            children: [
              // Ícono grande en la parte superior
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 8),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: service['iconColor'].withOpacity(0.2),
                  child: Icon(
                    service['icon'],
                    size: 50,
                    color: service['iconColor'],
                  ),
                ),
              ),
              // Título y botón
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['name'],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service['professional'],
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _processBooking(service);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(90, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reservar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 1, color: lightGray),
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calificación con estrellas
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            service['rating'].toString(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '(15 reseñas)',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: mediumGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Detalles del servicio
                      const Text(
                        'Detalles del servicio',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['description'],
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: darkGray,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Costo: \$${service['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, thickness: 1, color: lightGray),

                      // Reseñas
                      const SizedBox(height: 16),
                      const Text(
                        'Reseñas',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(15 reseñas)',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          color: mediumGray,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista de reseñas
                      ...reviews.map((review) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['name']!,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: darkGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  review['comment']!,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 14,
                                    color: mediumGray,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processBooking(Map<String, dynamic> service) async {
    // Simular proceso de reserva
    await Future.delayed(const Duration(seconds: 1));

    // Simular éxito/error aleatorio
    final random = DateTime.now().millisecondsSinceEpoch % 2;
    if (random == 0) {
      // Éxito
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } else {
      // Error
      setState(() {
        _showError = true;
        _errorMessage = 'No se pudo realizar la reserva';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showError = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.subcategoryName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: primaryBlue,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Buscador
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                      hintText: 'Buscar el servicio que necesitas',
                      hintStyle: TextStyle(fontFamily: 'Roboto', color: mediumGray),
                      prefixIcon: Icon(Icons.search_rounded, color: mediumGray),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: mediumGray),
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

              // Filtros de ordenamiento
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSortButton(
                        icon: Icons.star_rounded,
                        label: 'Mejor calificados',
                        isSelected: _selectedSort == 'Calificación' && !_sortAscending,
                        onTap: () {
                          setState(() {
                            if (_selectedSort == 'Calificación') {
                              _sortAscending = !_sortAscending;
                            } else {
                              _selectedSort = 'Calificación';
                              _sortAscending = false;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSortButton(
                        icon: Icons.attach_money_rounded,
                        label: 'Precio',
                        isSelected: _selectedSort == 'Precio',
                        onTap: () {
                          setState(() {
                            if (_selectedSort == 'Precio') {
                              _sortAscending = !_sortAscending;
                            } else {
                              _selectedSort = 'Precio';
                              _sortAscending = false;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros por tipo
              if (_availableTypes.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: _availableTypes.map((type) {
                      final isSelected = _selectedTypes.contains(type);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                          backgroundColor: Colors.white,
                          selectedColor: primaryBlue,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 13,
                            color: isSelected ? Colors.white : darkGray,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? primaryBlue : mediumGray.withOpacity(0.3)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Lista de servicios
              Expanded(
                child: _filteredServices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: mediumGray),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron servicios',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                color: mediumGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return _buildServiceCard(service);
                        },
                      ),
              ),
            ],
          ),

          // Modal de éxito
          if (_showSuccess)
            _buildModal(
              icon: Icons.check_circle,
              color: Colors.green,
              message: 'Reserva confirmada',
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

  Widget _buildSortButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: cardShadow, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : darkGray,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono izquierdo
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: service['iconColor'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service['icon'],
                size: 40,
                color: service['iconColor'],
              ),
            ),
            const SizedBox(width: 16),
            // Información derecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y calificación
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service['name'],
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkGray,
                          ),
                        ),
                      ),
                      _buildRatingStars(service['rating']),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['professional'],
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['description'],
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: mediumGray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showBookingDialog(service);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reservar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    double fractional = rating - fullStars;
    bool hasHalf = fractional >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < fullStars) {
          return const Icon(Icons.star_rounded, color: Colors.orange, size: 16);
        } else if (i == fullStars && hasHalf) {
          return const Icon(Icons.star_half_rounded, color: Colors.orange, size: 16);
        } else {
          return Icon(Icons.star_border_rounded, color: Colors.orange.withOpacity(0.3), size: 16);
        }
      }),
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
              Icon(
                icon,
                size: 70,
                color: color,
              ),
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