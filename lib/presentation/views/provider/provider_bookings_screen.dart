import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/booking_model.dart';
import 'package:servizone_app/presentation/views/provider/provider_home_screen.dart';
import 'package:servizone_app/presentation/views/provider/services/provider_services_screen.dart';
import 'package:servizone_app/presentation/views/provider/profile/provider_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:servizone_app/core/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  int _monthsFilter = 1;
  BookingStatus? _statusFilter;
  
  final List<BookingModel> _allBookings = [
    BookingModel(
      id: '1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Ana García',
      serviceName: 'Plomería - Fuga de agua',
      date: DateTime.now().add(const Duration(days: 2)),
      address: 'Calle 100 # 20-30',
      price: 45000,
      status: BookingStatus.confirmada,
    ),
    BookingModel(
      id: '2',
      clientId: 'C2',
      providerId: 'P1',
      clientName: 'Pedro Martínez',
      serviceName: 'Electricidad - Cortocircuito',
      date: DateTime.now().add(const Duration(days: 5)),
      address: 'Calle 50 # 10-20',
      price: 60000,
      status: BookingStatus.pendiente,
    ),
    BookingModel(
      id: '3',
      clientId: 'C3',
      providerId: 'P1',
      clientName: 'Luis Rodríguez',
      serviceName: 'Limpieza de Hogar',
      date: DateTime.now().subtract(const Duration(days: 15)),
      address: 'Calle 80 # 40-50',
      price: 80000,
      status: BookingStatus.completada,
      rating: 4.8,
      review: 'Muy buen trabajo, recomendado.',
    ),
  ];

  List<BookingModel> get _filteredBookings {
    final now = DateTime.now();
    final filterDate = now.subtract(Duration(days: _monthsFilter * 30));
    
    return _allBookings.where((booking) {
      final dateMatch = booking.date.isAfter(filterDate);
      final statusMatch = _statusFilter == null || booking.status == _statusFilter;
      return dateMatch && statusMatch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: mediumGray, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por favor, indica el motivo de la cancelación:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('El motivo de cancelación es obligatorio'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }
              setState(() {
                final index = _allBookings.indexWhere((b) => b.id == booking.id);
                _allBookings[index] = booking.copyWith(
                  status: BookingStatus.cancelada,
                  cancellationReason: reasonController.text,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Reserva cancelada correctamente'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );
  }

  void _shareToWhatsApp(BookingModel booking) async {
    final text = 'Hola ${booking.clientName}, te escribo por tu reserva de ${booking.serviceName} para el ${DateFormat('dd/MM/yyyy').format(booking.date)} a las ${DateFormat('hh:mm a').format(booking.date)} en la dirección: ${booking.address}.';
    final url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
    }
  }

  void _showBookingDetails(BookingModel booking) {
    if (booking.status == BookingStatus.completada) {
      _showCompletedBookingDetails(booking);
      return;
    }
    
    final dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(booking.date));
    final timeController = TextEditingController(text: DateFormat('hh:mm a').format(booking.date));
    final addressController = TextEditingController(text: booking.address);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Detalles de la Reserva', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailField('Cliente', booking.clientName),
            _buildDetailField('Servicio', booking.serviceName),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Fecha', prefixIcon: Icon(Icons.calendar_today_rounded)),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: booking.date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) dateController.text = DateFormat('yyyy-MM-dd').format(date);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Hora', prefixIcon: Icon(Icons.access_time_rounded)),
              readOnly: true,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(booking.date),
                );
                if (time != null) timeController.text = time.format(context);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Dirección', prefixIcon: Icon(Icons.location_on_rounded)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(booking),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), foregroundColor: Colors.red),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _shareToWhatsApp(booking),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    child: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (dateController.text.isEmpty || timeController.text.isEmpty || addressController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('La fecha, hora y dirección son obligatorias'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    final index = _allBookings.indexWhere((b) => b.id == booking.id);
                    _allBookings[index] = booking.copyWith(
                      status: BookingStatus.confirmada,
                      address: addressController.text,
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reserva confirmada correctamente'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text('Confirmar Reserva'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showCompletedBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Reserva Completada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: const Text('COMPLETADA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailField('Cliente', booking.clientName),
            _buildDetailField('Servicio', booking.serviceName),
            _buildDetailField('Fecha y Hora', DateFormat('dd MMM yyyy - hh:mm a').format(booking.date)),
            _buildDetailField('Dirección', booking.address),
            if (booking.rating != null) ...[
              const Divider(height: 32),
              const Text('Calificación del Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < (booking.rating ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 24,
                )),
              ),
              if (booking.review != null && booking.review!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('"${booking.review}"', style: const TextStyle(fontStyle: FontStyle.italic, color: mediumGray)),
              ],
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: Colors.white,
        foregroundColor: darkGray,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuickFilters(),
          Expanded(
            child: _filteredBookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) => _buildBookingCard(_filteredBookings[index]),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          HapticFeedback.lightImpact();
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProviderServicesScreen()),
              );
              break;
            case 2:
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
            Text('Filtrar por Estado', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildStatusChip('Todas', _statusFilter == null, () => setState(() => _statusFilter = null)),
                _buildStatusChip('Pendientes', _statusFilter == BookingStatus.pendiente, () => setState(() => _statusFilter = BookingStatus.pendiente)),
                _buildStatusChip('Confirmadas', _statusFilter == BookingStatus.confirmada, () => setState(() => _statusFilter = BookingStatus.confirmada)),
                _buildStatusChip('Completadas', _statusFilter == BookingStatus.completada, () => setState(() => _statusFilter = BookingStatus.completada)),
                _buildStatusChip('Canceladas', _statusFilter == BookingStatus.cancelada, () => setState(() => _statusFilter = BookingStatus.cancelada)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: primaryBlue.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? primaryBlue : mediumGray,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('1 mes', _monthsFilter == 1, () => setState(() => _monthsFilter = 1)),
          _buildFilterChip('3 meses', _monthsFilter == 3, () => setState(() => _monthsFilter = 3)),
          _buildFilterChip('6 meses', _monthsFilter == 6, () => setState(() => _monthsFilter = 6)),
          const VerticalDivider(width: 20, indent: 10, endIndent: 10),
          _buildStatusChip('Todas', _statusFilter == null, () => setState(() => _statusFilter = null)),
          _buildStatusChip('Pendientes', _statusFilter == BookingStatus.pendiente, () => setState(() => _statusFilter = BookingStatus.pendiente)),
          _buildStatusChip('Confirmadas', _statusFilter == BookingStatus.confirmada, () => setState(() => _statusFilter = BookingStatus.confirmada)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: primaryBlue.withOpacity(0.2),
        checkmarkColor: primaryBlue,
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
      onTap: () => _showBookingDetails(booking),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_today_rounded, size: 20, color: statusColor),
          ),
          title: Text(booking.clientName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.serviceName, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: mediumGray),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd MMM - hh:mm a').format(booking.date), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
            child: Text(
              booking.status.name.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_rounded, size: 80, color: primaryBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No hay reservas registradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray)),
        ],
      ),
    );
  }
}
