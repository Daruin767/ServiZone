import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/core/routes/app_routes.dart';

class HomeClientScreen extends StatefulWidget {
  const HomeClientScreen({super.key});

  @override
  State<HomeClientScreen> createState() => _HomeClientScreenState();
}

class _HomeClientScreenState extends State<HomeClientScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 1; // Por defecto en Servicios (índice 1)
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
    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // Navegar al login
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildActivityScreen(),
      _buildSolicitudScreen(),
      _buildReservasScreen(),
      _buildAccountScreen(),
    ];

    return Scaffold(
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
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: primaryBlue,
        unselectedItemColor: mediumGray,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Actividad"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Servicios"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: "Reservas"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Cuenta"),
        ],
      ),
    );
  }

  Widget _buildActivityScreen() {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text("Historial de Solicitudes", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.history_rounded, size: 40, color: primaryBlue),
              ),
              const SizedBox(height: 24),
              const Text('No hay actividad reciente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkGray)),
              const SizedBox(height: 12),
              const Text('Tus solicitudes aparecerán aquí', style: TextStyle(color: mediumGray)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text('Explorar Servicios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudScreen() {
    final filteredCategories = categories
        .where((c) => c["title"].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: lightGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                          children: [
                            TextSpan(text: "Servi", style: TextStyle(color: primaryBlue)),
                            TextSpan(text: "Zone", style: TextStyle(color: darkGray)),
                          ],
                        ),
                      ),
                      const Text('Tu plataforma de servicios', style: TextStyle(color: mediumGray)),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Stack(
                    children: [
                      Icon(Icons.notifications_none_rounded, color: darkGray),
                      const Positioned(
                          right: 0, top: 0, child: CircleAvatar(radius: 4, backgroundColor: Colors.red)),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: cardShadow, blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration:
                                BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.add_location_alt_rounded, color: primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Agregar dirección',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: darkGray)),
                                const SizedBox(height: 2),
                                Text('Para servicios más precisos', style: TextStyle(color: mediumGray, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: mediumGray, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    onChanged: (v) => setState(() => searchQuery = v),
                    decoration: InputDecoration(
                      hintText: "¿Qué servicio necesitas?",
                      prefixIcon: Icon(Icons.search_rounded, color: mediumGray),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryBlue, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text('Categorías de Servicios',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                      const Spacer(),
                      Text('${filteredCategories.length} servicios', style: TextStyle(color: mediumGray)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryCard(filteredCategories[index]),
                childCount: filteredCategories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Aquí puedes navegar a la pantalla de servicios de esa categoría
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(category["subtitle"], style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservasScreen() {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text("Mis Reservas"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_rounded, size: 80, color: primaryBlue.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text(
              "No tienes reservas activas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: darkGray),
            ),
            const SizedBox(height: 10),
            const Text(
              "Las reservas que realices aparecerán aquí",
              style: TextStyle(color: mediumGray),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: const Text("Explorar servicios"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountScreen() {
    return Scaffold(
      backgroundColor: lightGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 80, color: primaryBlue),
            const SizedBox(height: 20),
            const Text('Perfil de Usuario', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Aquí puedes ver y editar tu perfil', style: TextStyle(color: mediumGray)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminDashboard),
              child: const Text('Ir a Admin (demo)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}