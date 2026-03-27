import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/core/locator.dart';
import 'package:servizone_app/data/providers/auth_service.dart';
import 'package:servizone_app/data/models/booking_model.dart';
import 'package:servizone_app/presentation/views/client/services/subcategory_screen.dart';
import 'package:servizone_app/presentation/views/client/profile/client_profile_screen.dart';
import 'package:servizone_app/presentation/views/client/client_requests_screen.dart';
import 'package:servizone_app/presentation/views/client/client_bookings_screen.dart';

class HomeClientScreen extends StatefulWidget {
  final int initialIndex;
  const HomeClientScreen({super.key, this.initialIndex = 2});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> categories = [
    {
      "title": "Servi Favor",
      "subtitle": "Favores personales",
      "icon": Icons.handshake_rounded,
      "color": primaryBlue,
      "gradient": [const Color(0xFF1A237E), const Color(0xFF3F51B5)],
      "keywords": ["mandados", "diligencias", "compras", "favor", "ayuda", "personal", "rápido"],
    },
    {
      "title": "Hogar",
      "subtitle": "Limpieza y mantenimiento",
      "icon": Icons.home_rounded,
      "color": const Color(0xFF2E7D32),
      "gradient": [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
      "keywords": ["limpieza", "plomería", "electricidad", "carpintería", "pintura", "reparación", "mantenimiento", "casa", "aseo", "arreglos"],
    },
    {
      "title": "Ciclismo",
      "subtitle": "Reparación y servicios",
      "icon": Icons.directions_bike_rounded,
      "color": const Color(0xFFE65100),
      "gradient": [const Color(0xFFE65100), const Color(0xFFFF9800)],
      "keywords": ["bicicleta", "bici", "reparación", "mantenimiento", "llanta", "frenos", "cadena", "taller", "mecánica"],
    },
    {
      "title": "Cuidado",
      "subtitle": "Cuidado de personas",
      "icon": Icons.favorite_rounded,
      "color": const Color(0xFFC2185B),
      "gradient": [const Color(0xFFC2185B), const Color(0xFFE91E63)],
      "keywords": ["niñera", "ancianos", "enfermera", "enfermería", "cuidado", "acompañamiento", "salud", "niños", "adulto mayor"],
    },
    {
      "title": "Cuidado Personal",
      "subtitle": "Belleza y bienestar",
      "icon": Icons.spa_rounded,
      "color": const Color(0xFF7B1FA2),
      "gradient": [const Color(0xFF7B1FA2), const Color(0xFF9C27B0)],
      "keywords": ["belleza", "spa", "masaje", "corte", "cabello", "maquillaje", "uñas", "manicure", "pedicure", "barbería", "peluquería", "estética"],
    },
    {
      "title": "Mascotas",
      "subtitle": "Cuidado animal",
      "icon": Icons.pets_rounded,
      "color": const Color(0xFFD32F2F),
      "gradient": [const Color(0xFFD32F2F), const Color(0xFFF44336)],
      "keywords": ["perros", "gatos", "paseo", "veterinario", "baño", "peluquería", "animales", "cuidado", "adiestramiento"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await locator<AuthService>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtrar Categorías', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textGray)),
            const SizedBox(height: 20),
            _buildFilterOption('Todas', true, () {}),
            _buildFilterOption('Hogar', false, () {}),
            _buildFilterOption('Mascotas', false, () {}),
            _buildFilterOption('Belleza', false, () {}),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Aplicar', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
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
    final List<Widget> screens = [
      _buildReservasScreen(),  // 0: Reservas
      _buildSolicitudesTab(),  // 1: Solicitudes
      _buildServiciosScreen(), // 2: Servicios
      _buildAccountScreen(),   // 3: Perfil
    ];

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: (_currentIndex == 3) 
        ? AppBar(
            title: const Text("Perfil", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: textGray,
            elevation: 0,
          ) 
        : null,
      body: screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          _fadeController.reset();
          _slideController.reset();
          _fadeController.forward();
          _slideController.forward();
        },
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textGray,
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12),
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

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController(text: searchQuery);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Buscar Servicios'),
        content: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ej: Plomería, Mascotas...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onSubmitted: (value) {
            setState(() => searchQuery = value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => searchQuery = "");
              Navigator.pop(context);
            },
            child: const Text('Limpiar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => searchQuery = searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  // Pantalla Solicitudes (usa ClientRequestsScreen)
  Widget _buildSolicitudesTab() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: const ClientRequestsScreen(),
      ),
    );
  }

  // Pantalla Servicios (categorías)
  Widget _buildServiciosScreen() {
    final filteredCategories = categories.where((category) {
      final query = searchQuery.toLowerCase();
      final titleMatch = category["title"].toLowerCase().contains(query);
      final subtitleMatch = category["subtitle"].toLowerCase().contains(query);
      final keywords = (category["keywords"] as List<String>?) ?? [];
      final keywordMatch = keywords.any((k) => k.toLowerCase().contains(query));
      return titleMatch || subtitleMatch || keywordMatch;
    }).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.displayLarge,
                          children: [
                            const TextSpan(text: "Servi", style: TextStyle(color: primaryBlue)),
                            TextSpan(text: "Zone", style: TextStyle(color: darkGray)),
                          ],
                        ),
                      ),
                      Text('Tu plataforma de servicios', 
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Roboto')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Barra de Búsqueda
            _buildSearchBar(),

            const SizedBox(height: 30),

            // Título de Categorías
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('Categorías de Servicios',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  Text('${filteredCategories.length} servicios', 
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Roboto')),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid de Categorías
            Expanded(
              child: filteredCategories.isEmpty
                  ? _buildNoResults()
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) => _buildCategoryCard(filteredCategories[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Center(
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          style: const TextStyle(fontSize: 16, color: darkGray, fontFamily: 'Roboto'),
          decoration: InputDecoration(
            hintText: 'Ej: Plomería, Mascotas...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: textGray.withValues(alpha: 0.8), fontSize: 16, fontFamily: 'Roboto'),
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.search_rounded, color: primaryBlue, size: 28),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 22, color: textGray),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => searchQuery = "");
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: textGray.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No se encontraron resultados', style: TextStyle(fontWeight: FontWeight.bold, color: darkGray)),
          const Text('Intenta con otra palabra clave', style: TextStyle(color: textGray)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubcategoryScreen(
              categoryName: category["title"],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: category["gradient"]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: category["color"].withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(category["icon"], color: Colors.white),
              ),
              const Spacer(),
              Text(category["title"],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(category["subtitle"], 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Roboto',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // Pantalla Reservas (solo confirmadas/completadas)
  Widget _buildReservasScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: const ClientBookingsScreen(),
      ),
    );
  }

  // Pantalla Cuenta (usa ClientProfileScreen)
  Widget _buildAccountScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ClientProfileScreen(onLogout: _logout),
      ),
    );
  }
}


