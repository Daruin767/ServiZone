import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/presentation/views/client/services/service_detail_screen.dart';

class ServiceListScreen extends StatefulWidget {
  final String categoryName;
  final String subcategoryName;
  final bool isGuest;

  const ServiceListScreen({
    super.key,
    required this.categoryName,
    required this.subcategoryName,
    this.isGuest = false,
  });

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSort = 'rating'; // 'rating', 'price_desc', 'price_asc'
  final Set<String> _selectedTypes = {};

  // Estados para los modales de éxito/error
  bool _isLoading = false;

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
        'iconColor': primaryBlue,
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

    if (_selectedSort == 'rating') {
      filtered.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (_selectedSort == 'price_desc') {
      filtered.sort((a, b) => b['price'].compareTo(a['price']));
    } else if (_selectedSort == 'price_asc') {
      filtered.sort((a, b) => a['price'].compareTo(b['price']));
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showGuestLoginModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              child: const Icon(Icons.lock_outline_rounded, color: primaryBlue, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Inicia sesión para reservar!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'Para poder agendar este servicio y gestionar tus reservas, necesitas tener una cuenta en ServiZone.',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15,
            color: darkGray,
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/auth/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Iniciar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryBlue),
                    foregroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continuar explorando', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(Map<String, dynamic> service) {
    if (widget.isGuest) {
      _showGuestLoginModal();
      return;
    }
    
    // Nueva pantalla de detalle con estilo minimalista
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(service: service),
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: darkGray),
            onSelected: (value) {
              if (value == 'sort_rating') {
                setState(() => _selectedSort = 'rating');
              } else if (value == 'sort_price_desc') {
                setState(() => _selectedSort = 'price_desc');
              } else if (value == 'sort_price_asc') {
                setState(() => _selectedSort = 'price_asc');
              } else if (value.startsWith('type_')) {
                final type = value.substring(5);
                setState(() {
                  if (_selectedTypes.contains(type)) {
                    _selectedTypes.remove(type);
                  } else {
                    _selectedTypes.add(type);
                  }
                });
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [];
              items.add(const PopupMenuItem(
                enabled: false,
                child: Text('Filtrar por Tipo:', style: TextStyle(fontWeight: FontWeight.bold, color: textGray, fontSize: 12)),
              ));
              for (final type in _availableTypes) {
                items.add(PopupMenuItem<String>(
                  value: 'type_$type',
                  child: Row(
                    children: [
                      Icon(
                        _selectedTypes.contains(type) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        color: primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(type),
                    ],
                  ),
                ));
              }
              items.add(const PopupMenuDivider());
              items.add(const PopupMenuItem(
                enabled: false,
                child: Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.bold, color: textGray, fontSize: 12)),
              ));
              items.add(PopupMenuItem<String>(
                value: 'sort_rating',
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: _selectedSort == 'rating' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Mejor calificados'),
                  ],
                ),
              ));
              items.add(PopupMenuItem<String>(
                value: 'sort_price_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, color: _selectedSort == 'price_desc' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Precio: mayor a menor'),
                  ],
                ),
              ));
              items.add(PopupMenuItem<String>(
                value: 'sort_price_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: _selectedSort == 'price_asc' ? primaryBlue : textGray, size: 20),
                    const SizedBox(width: 12),
                    const Text('Precio: menor a mayor'),
                  ],
                ),
              ));
              return items;
            },
          )
        ],
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
                      hintStyle: TextStyle(fontFamily: 'Roboto', color: textGray),
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

              // Lista de servicios
              Expanded(
                child: _filteredServices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: textGray),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron servicios',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                color: textGray,
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

          // Indicador de carga centralizado
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: primaryBlue),
                      SizedBox(height: 20),
                      Text(
                        'Procesando reserva...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
                color: service['iconColor'].withValues(alpha: 0.2),
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
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service['description'],
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: textGray,
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
          return Icon(Icons.star_border_rounded, color: Colors.orange.withValues(alpha: 0.3), size: 16);
        }
      }),
    );
  }
}


