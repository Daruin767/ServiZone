import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:servizone_app/presentation/views/client/services/subcategory_screen.dart';
import 'package:servizone_app/presentation/views/client/profile/client_profile_screen.dart';
import 'package:servizone_app/presentation/views/client/client_bookings_screen.dart';

class HomeClientScreen extends StatefulWidget {
  final int initialIndex;
  const HomeClientScreen({super.key, this.initialIndex = 1});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen>
    with TickerProviderStateMixin {
  late int _currentIndex;
  String searchQuery = "";

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
    },
    {
      "title": "Hogar",
      "subtitle": "Limpieza y mantenimiento",
      "icon": Icons.home_rounded,
      "color": const Color(0xFF2E7D32),
      "gradient": [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
    },
    {
      "title": "Ciclismo",
      "subtitle": "Reparación y servicios",
      "icon": Icons.directions_bike_rounded,
      "color": const Color(0xFFE65100),
      "gradient": [const Color(0xFFE65100), const Color(0xFFFF9800)],
    },
    {
      "title": "Cuidado",
      "subtitle": "Cuidado de personas",
      "icon": Icons.favorite_rounded,
      "color": const Color(0xFFC2185B),
      "gradient": [const Color(0xFFC2185B), const Color(0xFFE91E63)],
    },
    {
      "title": "Cuidado Personal",
      "subtitle": "Belleza y bienestar",
      "icon": Icons.spa_rounded,
      "color": const Color(0xFF7B1FA2),
      "gradient": [const Color(0xFF7B1FA2), const Color(0xFF9C27B0)],
    },
    {
      "title": "Mascotas",
      "subtitle": "Cuidado animal",
      "icon": Icons.pets_rounded,
      "color": const Color(0xFFD32F2F),
      "gradient": [const Color(0xFFD32F2F), const Color(0xFFF44336)],
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
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildReservasScreen(),
      _buildSolicitudScreen(),
      _buildAccountScreen(),
    ];

    return Scaffold(
      backgroundColor: lightGray,
      appBar: _currentIndex == 1 ? null : AppBar(
        title: Text(
          _currentIndex == 0 ? "Mis Reservas" : "Mi Perfil",
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: darkGray,
        elevation: 0,
        actions: _currentIndex == 0 ? [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.filter_list_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Usa los filtros rápidos en la parte superior de la lista'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                );
              },
            ),
          ),
        ] : null,
      ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mediumGray,
        selectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Reservas"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Servicios"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Cuenta"),
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

  // Pantalla Servicios (categorías)
  Widget _buildSolicitudScreen() {
    final filteredCategories = categories.where((category) {
      final titleMatch = category["title"].toLowerCase().contains(searchQuery.toLowerCase());
      final subtitleMatch = category["subtitle"].toLowerCase().contains(searchQuery.toLowerCase());
      return titleMatch || subtitleMatch;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayLarge,
                      children: [
                        const TextSpan(text: "Servi", style: TextStyle(color: primaryBlue)),
                        TextSpan(text: "Zone", style: TextStyle(color: darkGray.withOpacity(0.8))),
                      ],
                    ),
                  ),
                  Text('Tu plataforma de servicios', 
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'Roboto')),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: mediumGray),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              onSubmitted: (value) {
                // Aquí se podría navegar a una pantalla de resultados global
                // Por ahora el filtrado es reactivo en el grid
              },
              decoration: const InputDecoration(
                hintText: 'Buscar servicios...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: mediumGray),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20, color: mediumGray),
              onPressed: () => setState(() => searchQuery = ""),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: mediumGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No se encontraron resultados', style: TextStyle(fontWeight: FontWeight.bold, color: darkGray)),
          const Text('Intenta con otra palabra clave', style: TextStyle(color: mediumGray)),
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
          boxShadow: [BoxShadow(color: category["color"].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(category["icon"], color: Colors.white),
              ),
              const Spacer(),
              Text(category["title"],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(category["subtitle"], 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontFamily: 'Roboto',
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // Pantalla Reservas
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
