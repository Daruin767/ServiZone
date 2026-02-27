import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/provider_model.dart';

class ProvidersManagementScreen extends StatefulWidget {
  const ProvidersManagementScreen({super.key});

  @override
  State<ProvidersManagementScreen> createState() => _ProvidersManagementScreenState();
}

class _ProvidersManagementScreenState extends State<ProvidersManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<ProviderModel> providers = [
    ProviderModel(
      id: '001',
      name: 'Carlos Mendoza',
      email: 'carlos.mendoza@email.com',
      phone: '+57 300 123 4567',
      category: 'Plomería',
      address: 'Calle 45 #12-34, Medellín',
      rating: 4.8,
      completedServices: 156,
      isActive: true,
      isVerified: true,
      joinDate: DateTime.now().subtract(const Duration(days: 180)),
    ),
    ProviderModel(
      id: '002',
      name: 'Ana García López',
      email: 'ana.garcia@email.com',
      phone: '+57 301 987 6543',
      category: 'Limpieza',
      address: 'Carrera 70 #23-45, Bogotá',
      rating: 4.9,
      completedServices: 203,
      isActive: true,
      isVerified: true,
      joinDate: DateTime.now().subtract(const Duration(days: 120)),
    ),
    ProviderModel(
      id: '003',
      name: 'Roberto Silva',
      email: 'roberto.silva@email.com',
      phone: '+57 302 456 7890',
      category: 'Electricidad',
      address: 'Av. 80 #15-67, Cali',
      rating: 4.6,
      completedServices: 89,
      isActive: false,
      isVerified: true,
      joinDate: DateTime.now().subtract(const Duration(days: 90)),
    ),
    ProviderModel(
      id: '004',
      name: 'María Fernández',
      email: 'maria.fernandez@email.com',
      phone: '+57 303 789 0123',
      category: 'Jardinería',
      address: 'Clle 123 #45-67, Barranquilla',
      rating: 4.7,
      completedServices: 134,
      isActive: true,
      isVerified: false,
      joinDate: DateTime.now().subtract(const Duration(days: 45)),
    ),
    ProviderModel(
      id: '005',
      name: 'Luis Rodríguez',
      email: 'luis.rodriguez@email.com',
      phone: '+57 304 234 5678',
      category: 'Carpintería',
      address: 'Carrera 15 #89-12, Bucaramanga',
      rating: 4.5,
      completedServices: 67,
      isActive: true,
      isVerified: true,
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  List<ProviderModel> filteredProviders = [];
  String searchQuery = '';
  String selectedCategory = 'Todos';
  String selectedStatus = 'Todos';
  bool isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProviders = List.from(providers);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterProviders() {
    setState(() {
      filteredProviders = providers.where((p) {
        bool matchesSearch = searchQuery.isEmpty ||
            p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.email.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.category.toLowerCase().contains(searchQuery.toLowerCase());
        bool matchesCategory = selectedCategory == 'Todos' || p.category == selectedCategory;
        bool matchesStatus = selectedStatus == 'Todos' ||
            (selectedStatus == 'Activos' && p.isActive) ||
            (selectedStatus == 'Inactivos' && !p.isActive) ||
            (selectedStatus == 'Verificados' && p.isVerified) ||
            (selectedStatus == 'No Verificados' && !p.isVerified);
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  void _showProviderDetails(ProviderModel provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryBlue, lightBlue]), shape: BoxShape.circle),
                    child: Center(child: Text(provider.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                        const SizedBox(height: 4),
                        Text(provider.category, style: TextStyle(fontSize: 14, color: primaryBlue, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Email', provider.email, Icons.email_rounded),
                      _buildDetailRow('Teléfono', provider.phone, Icons.phone_rounded),
                      _buildDetailRow('Dirección', provider.address, Icons.location_on_rounded),
                      _buildDetailRow('Servicios Completados', '${provider.completedServices}', Icons.work_rounded),
                      _buildDetailRow('Calificación', '${provider.rating}/5.0', Icons.star_rounded),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildStatusChip('Activo', provider.isActive, Colors.green),
                          const SizedBox(width: 12),
                          _buildStatusChip('Verificado', provider.isVerified, primaryBlue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditProviderDialog(provider);
                      },
                      child: const Text('Editar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: mediumGray, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: darkGray, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProviderDialog(ProviderModel provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando: ${provider.name}'), backgroundColor: primaryBlue, behavior: SnackBarBehavior.floating),
    );
  }

  void _showFilters() {
    final categories = ['Todos', 'Plomería', 'Limpieza', 'Electricidad', 'Jardinería', 'Carpintería'];
    final statuses = ['Todos', 'Activos', 'Inactivos', 'Verificados', 'No Verificados'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
              const SizedBox(height: 24),
              const Text('Categoría', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: categories.map((c) => FilterChip(
                  label: Text(c),
                  selected: selectedCategory == c,
                  onSelected: (selected) {
                    setBottomSheetState(() => selectedCategory = c);
                    setState(() => selectedCategory = c);
                    _filterProviders();
                  },
                  selectedColor: primaryBlue.withOpacity(0.2),
                  checkmarkColor: primaryBlue,
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Estado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: darkGray)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: statuses.map((s) => FilterChip(
                  label: Text(s),
                  selected: selectedStatus == s,
                  onSelected: (selected) {
                    setBottomSheetState(() => selectedStatus = s);
                    setState(() => selectedStatus = s);
                    _filterProviders();
                  },
                  selectedColor: primaryBlue.withOpacity(0.2),
                  checkmarkColor: primaryBlue,
                )).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = 'Todos';
                          selectedStatus = 'Todos';
                        });
                        _filterProviders();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard(ProviderModel provider, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animation, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - animation)),
          child: Opacity(
            opacity: animation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10)],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showProviderDetails(provider),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(gradient: LinearGradient(colors: [primaryBlue, lightBlue]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryBlue, blurRadius: 10)]),
                              child: Center(child: Text(provider.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(provider.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray)),
                                  const SizedBox(height: 4),
                                  Text(provider.category, style: TextStyle(fontSize: 14, color: primaryBlue, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'details') _showProviderDetails(provider);
                                else if (value == 'edit') _showEditProviderDialog(provider);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'details', child: Row(children: [Icon(Icons.info_outline_rounded), SizedBox(width: 8), Text('Ver detalles')])),
                                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded), SizedBox(width: 8), Text('Editar')])),
                              ],
                              child: Container(padding: const EdgeInsets.all(8), child: Icon(Icons.more_vert_rounded, color: mediumGray)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.email_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 8),
                            Expanded(child: Text(provider.email, style: const TextStyle(fontSize: 14, color: mediumGray), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded, size: 16, color: mediumGray),
                            const SizedBox(width: 8),
                            Text(provider.phone, style: const TextStyle(fontSize: 14, color: mediumGray)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(provider.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text('${provider.completedServices} servicios', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                            ),
                            const Spacer(),
                            _buildStatusChip('Activo', provider.isActive, Colors.green),
                            const SizedBox(width: 8),
                            _buildStatusChip('Verificado', provider.isVerified, primaryBlue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String label, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : mediumGray.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? color.withOpacity(0.3) : mediumGray.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? color : mediumGray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.business_rounded, color: primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      const Text('Gestión de Proveedores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkGray)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Text('${filteredProviders.length} proveedores', style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            searchQuery = value;
                            _filterProviders();
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar proveedores...',
                            prefixIcon: Icon(Icons.search_rounded, color: mediumGray),
                            suffixIcon: searchQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear_rounded, color: mediumGray), onPressed: () { _searchController.clear(); searchQuery = ''; _filterProviders(); }) : null,
                            filled: true,
                            fillColor: lightGray,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryBlue, width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: _showFilters,
                          style: IconButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredProviders.isEmpty
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(color: mediumGray.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.business_rounded, size: 40, color: mediumGray),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            searchQuery.isNotEmpty ? 'No se encontraron proveedores' : 'No hay proveedores registrados',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: mediumGray),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, index) => _buildProviderCard(filteredProviders[index], index),
                  ),
          ),
        ],
      ),
    );
  }
}