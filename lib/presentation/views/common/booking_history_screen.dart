import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/booking_model.dart';
import 'package:servizone_app/core/services/booking_filter_service.dart';

class BookingHistoryScreen extends StatefulWidget {
  final bool isProvider;

  const BookingHistoryScreen({super.key, this.isProvider = false});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BookingStatus? _statusFilter;
  BookingPeriod _selectedPeriod = BookingPeriod.all;
  bool _isLoading = false;
  String? _serviceTypeFilter;
  
  // Datos de ejemplo extendidos para el historial
  final List<BookingModel> _allBookings = [
    BookingModel(
      id: 'H1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Juan Pérez',
      providerName: 'Carlos Electrics',
      serviceName: 'Electricidad - Cortocircuito',
      date: DateTime.now().subtract(const Duration(days: 45)),
      address: 'Calle 123 # 45-67',
      price: 60000,
      status: BookingStatus.completada,
      rating: 5.0,
      review: 'Excelente trabajo, muy profesional.',
    ),
    BookingModel(
      id: 'H2',
      clientId: 'C2',
      providerId: 'P2',
      clientName: 'María García',
      providerName: 'Plomería Express',
      serviceName: 'Plomería - Fuga de agua',
      date: DateTime.now().subtract(const Duration(days: 30)),
      address: 'Av. Siempre Viva 742',
      price: 45000,
      status: BookingStatus.cancelada,
      cancellationReason: 'El cliente no se encontraba en casa.',
    ),
    BookingModel(
      id: 'H3',
      clientId: 'C1',
      providerId: 'P3',
      clientName: 'Juan Pérez',
      providerName: 'Limpieza Total',
      serviceName: 'Limpieza de Hogar',
      date: DateTime.now().subtract(const Duration(days: 15)),
      address: 'Calle 123 # 45-67',
      price: 80000,
      status: BookingStatus.completada,
      rating: 4.0,
    ),
    BookingModel(
      id: 'H4',
      clientId: 'C3',
      providerId: 'P4',
      clientName: 'Roberto Gómez',
      providerName: 'Mascota Feliz',
      serviceName: 'Paseo de perros',
      date: DateTime.now().add(const Duration(days: 2)),
      address: 'Carrera 10 # 20-30',
      price: 25000,
      status: BookingStatus.pendiente,
    ),
    BookingModel(
      id: 'H5',
      clientId: 'C4',
      providerId: 'P5',
      clientName: 'Ana Martínez',
      providerName: 'Belleza en Casa',
      serviceName: 'Manicura y Pedicura',
      date: DateTime.now().subtract(const Duration(days: 60)),
      address: 'Calle 50 # 10-20',
      price: 35000,
      status: BookingStatus.completada,
      rating: 4.5,
      review: 'Muy detallista y amable.',
    ),
  ];

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('user_id') ?? (widget.isProvider ? 'P1' : 'C1');
    });
  }

  List<BookingModel> get _filteredBookings {
    return _allBookings.where((booking) {
      // Separación de datos por user_id y role_type
      final bool belongsToUser = widget.isProvider 
          ? booking.providerId == _currentUserId 
          : booking.clientId == _currentUserId;

      if (!belongsToUser) return false;

      // Filtro de búsqueda (Nombre de servicio, cliente o proveedor)
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = booking.serviceName.toLowerCase().contains(searchLower) ||
          booking.clientName.toLowerCase().contains(searchLower) ||
          (booking.providerName?.toLowerCase().contains(searchLower) ?? false);

      // Filtro de estado
      final matchesStatus = _statusFilter == null || booking.status == _statusFilter;

      // Filtro de período temporal (Sustituye rango de fechas manual)
      final matchesDate = BookingFilterService.isWithinPeriod(booking.date, _selectedPeriod);

      // Filtro de tipo de servicio
      final matchesService = _serviceTypeFilter == null || 
                             booking.serviceName.contains(_serviceTypeFilter!);

      return matchesSearch && matchesStatus && matchesDate && matchesService;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _selectedPeriod = BookingPeriod.all;
      _serviceTypeFilter = null;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  Future<void> _updatePeriod(BookingPeriod? period) async {
    if (period == null || period == _selectedPeriod) return;
    
    setState(() {
      _isLoading = true;
      _selectedPeriod = period;
    });

    // Simular petición asíncrona al backend (< 300ms req)
    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.isProvider ? 'Mis Servicios Recibidos' : 'Mi Historial de Reservas',
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildPeriodSelector(), // Selector de período robusto
          if (_statusFilter != null || _serviceTypeFilter != null)
            _buildActiveFilters(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : _filteredBookings.isEmpty
                    ? _buildEmptyState()
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: ListView.builder(
                          key: ValueKey(_selectedPeriod),
                          padding: const EdgeInsets.all(20),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) => _buildBookingCard(_filteredBookings[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: BookingPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(BookingFilterService.getPeriodLabel(period)),
              selected: isSelected,
              onSelected: (_) => _updatePeriod(period),
              selectedColor: primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : darkGray,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: lightGray,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Buscar por servicio, ${widget.isProvider ? 'cliente' : 'proveedor'}...',
          hintStyle: const TextStyle(color: mediumGray),
          prefixIcon: const Icon(Icons.search_rounded, color: mediumGray),
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF2C2C2C) 
              : lightGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (_statusFilter != null)
            _buildFilterChip(
              _statusFilter!.name.toUpperCase(),
              () => setState(() => _statusFilter = null),
            ),
          if (_serviceTypeFilter != null)
            _buildFilterChip(
              _serviceTypeFilter!,
              () => setState(() => _serviceTypeFilter = null),
            ),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpiar todos', style: TextStyle(color: primaryBlue, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)),
        backgroundColor: primaryBlue,
        deleteIcon: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filtros Avanzados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Reiniciar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Estado de la Reserva', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: BookingStatus.values.map((status) {
                  final isSelected = _statusFilter == status;
                  return ChoiceChip(
                    label: Text(status.name.toUpperCase(), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : darkGray)),
                    selected: isSelected,
                    selectedColor: primaryBlue,
                    onSelected: (val) => setState(() => _statusFilter = val ? status : null),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Tipo de Servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGray)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['Mantenimiento', 'Instalación', 'Reparación', 'Emergencia'].map((type) {
                  final isSelected = _serviceTypeFilter == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (v) {
                      setSheetState(() => _serviceTypeFilter = v ? type : null);
                      setState(() => _serviceTypeFilter = v ? type : null);
                    },
                    selectedColor: primaryBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : darkGray),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    switch (booking.status) {
      case BookingStatus.pendiente: statusColor = Colors.orange; break;
      case BookingStatus.confirmada: statusColor = Colors.blue; break;
      case BookingStatus.completada: statusColor = Colors.green; break;
      case BookingStatus.cancelada: statusColor = Colors.red; break;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBookingDetails(booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E) 
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.build_rounded, color: statusColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.serviceName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(booking.status, statusColor),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                        widget.isProvider 
                          ? 'Cliente: ${booking.clientName.isNotEmpty ? booking.clientName : 'Desconocido'}' 
                          : 'Proveedor: ${booking.providerName != null && booking.providerName!.isNotEmpty ? booking.providerName : 'No asignado'}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8), 
                          fontSize: 13
                        ),
                      ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: mediumGray),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy - hh:mm a').format(booking.date),
                              style: const TextStyle(color: mediumGray, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: mediumGray),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                booking.address,
                                style: const TextStyle(color: mediumGray, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (booking.status == BookingStatus.completada && booking.rating != null)
              _buildRatingSummary(booking),
            if (booking.status == BookingStatus.cancelada && booking.cancellationReason != null)
              _buildCancellationReason(booking.cancellationReason!),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Precio: \$${NumberFormat('#,###').format(booking.price)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showBookingDetails(booking);
                    },
                    child: const Text('Ver detalles'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRatingSummary(BookingModel booking) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Calificación: ', style: TextStyle(fontSize: 12, color: darkGray)),
              ...List.generate(5, (index) => Icon(
                index < (booking.rating ?? 0).floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 16,
              )),
              Text(' (${booking.rating})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          if (booking.review != null && booking.review!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '"${booking.review}"',
                style: const TextStyle(fontSize: 12, color: mediumGray, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCancellationReason(String reason) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 14, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Motivo: $reason',
              style: const TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[800] 
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalles de la Reserva',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status, _getStatusColor(booking.status)),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailItem('ID de Reserva', '#${booking.id}'),
            _buildDetailItem('Servicio', booking.serviceName),
            
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Fecha y Hora', 
                    DateFormat('EEEE, dd MMMM yyyy - hh:mm a').format(booking.date),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    'Precio Total', 
                    '\$${NumberFormat('#,###').format(booking.price)}',
                    textColor: primaryBlue,
                  ),
                ),
              ],
            ),
            
            _buildDetailItem('Dirección', booking.address),
            
            Divider(height: 32, color: Theme.of(context).dividerColor),
            Text(
              'Participantes',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDetailItem('Cliente', booking.clientName)),
                Expanded(child: _buildDetailItem('Proveedor', booking.providerName ?? 'No asignado')),
              ],
            ),
            
            if (booking.status == BookingStatus.cancelada) ...[
              Divider(height: 32, color: Theme.of(context).dividerColor),
              _buildDetailItem(
                'Motivo de Cancelación', 
                booking.cancellationReason ?? 'No especificado',
                textColor: Colors.red,
              ),
            ],
            
            if (booking.rating != null) ...[
              Divider(height: 32, color: Theme.of(context).dividerColor),
              Text(
                'Reseña y Calificación',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ...List.generate(5, (index) => Icon(
                    index < (booking.rating ?? 0).floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 24,
                  )),
                  const SizedBox(width: 12),
                  Text(
                    '(${booking.rating})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (booking.review != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '"${booking.review}"',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                      color: mediumGray,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: mediumGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pendiente: return Colors.orange;
      case BookingStatus.confirmada: return Colors.blue;
      case BookingStatus.completada: return Colors.green;
      case BookingStatus.cancelada: return Colors.red;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: primaryBlue.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('No se encontraron reservas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray)),
            const Text('Ajusta los filtros para ver más resultados', style: TextStyle(color: mediumGray)),
          ],
        ),
      ),
    );
  }
}
