import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:servizone_app/core/constants/app_constants.dart';
import 'package:servizone_app/data/models/booking_model.dart';

class ClientBookingsScreen extends StatefulWidget {
  const ClientBookingsScreen({super.key});

  @override
  State<ClientBookingsScreen> createState() => _ClientBookingsScreenState();
}

class _ClientBookingsScreenState extends State<ClientBookingsScreen> {
  int _monthsFilter = 1;
  BookingStatus? _statusFilter;
  
  // Datos de ejemplo para las reservas
  final List<BookingModel> _allBookings = [
    BookingModel(
      id: '1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Juan Pérez',
      serviceName: 'Plomería - Fuga de agua',
      date: DateTime.now().subtract(const Duration(days: 2)),
      address: 'Calle 123 # 45-67',
      price: 45000,
      status: BookingStatus.confirmada,
      providerName: 'Carlos Electrics',
    ),
    BookingModel(
      id: '2',
      clientId: 'C1',
      providerId: 'P2',
      clientName: 'Juan Pérez',
      serviceName: 'Electricidad - Cortocircuito',
      date: DateTime.now().subtract(const Duration(days: 5)),
      address: 'Calle 123 # 45-67',
      price: 60000,
      status: BookingStatus.pendiente,
      providerName: 'Electricistas Ya',
    ),
    BookingModel(
      id: '3',
      clientId: 'C1',
      providerId: 'P3',
      clientName: 'Juan Pérez',
      serviceName: 'Limpieza de Hogar',
      date: DateTime.now().subtract(const Duration(days: 15)),
      address: 'Calle 123 # 45-67',
      price: 80000,
      status: BookingStatus.completada,
      rating: 4.5,
      review: 'Excelente servicio, muy puntual.',
      providerName: 'Limpieza Pro',
    ),
    BookingModel(
      id: '4',
      clientId: 'C1',
      providerId: 'P4',
      clientName: 'Juan Pérez',
      serviceName: 'Cuidado de Mascotas',
      date: DateTime.now().subtract(const Duration(days: 45)),
      address: 'Calle 123 # 45-67',
      price: 35000,
      status: BookingStatus.cancelada,
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

  void _showNotification(String message, {bool isError = false}) {
    if (isError) {
      HapticFeedback.vibrate();
    } else {
      HapticFeedback.lightImpact();
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? errorRed : successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar Reserva', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Estás seguro de que deseas cancelar esta reserva?', style: TextStyle(color: darkGray)),
            const SizedBox(height: 16),
            const Text('Motivo de cancelación', style: TextStyle(fontSize: 12, color: mediumGray)),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Explica brevemente el motivo...',
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: lightGray,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: primaryBlue),
                  ),
                  child: const Text('Volver', style: TextStyle(color: primaryBlue)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (reasonController.text.trim().isEmpty) {
                      _showNotification('El motivo es obligatorio', isError: true);
                      return;
                    }
                    setState(() {
                      final index = _allBookings.indexWhere((b) => b.id == booking.id);
                      _allBookings[index] = booking.copyWith(
                        status: BookingStatus.cancelada,
                        cancellationReason: reasonController.text,
                      );
                    });
                    Navigator.pop(ctx);
                    _showNotification('Reserva cancelada correctamente');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BookingModel booking) {
    double selectedRating = 5;
    final reviewController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Calificar Servicio', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(
                    index < selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () => setDialogState(() => selectedRating = index + 1.0),
                )),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Comparte tu experiencia...',
                  hintStyle: const TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: lightGray,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cerrar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final index = _allBookings.indexWhere((b) => b.id == booking.id);
                        _allBookings[index] = booking.copyWith(
                          rating: selectedRating,
                          review: reviewController.text,
                        );
                      });
                      Navigator.pop(ctx);
                      _showNotification('¡Gracias por tu calificación!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: successGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
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
          _buildStatusChipShort('Todas', _statusFilter == null, () => setState(() => _statusFilter = null)),
          _buildStatusChipShort('Pendientes', _statusFilter == BookingStatus.pendiente, () => setState(() => _statusFilter = BookingStatus.pendiente)),
          _buildStatusChipShort('Confirmadas', _statusFilter == BookingStatus.confirmada, () => setState(() => _statusFilter = BookingStatus.confirmada)),
        ],
      ),
    );
  }

  Widget _buildStatusChipShort(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: primaryBlue.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isSelected ? primaryBlue : mediumGray,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? primaryBlue : Colors.transparent),
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: const Text(
                    'Detalles de la Reserva',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkGray,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildDetailItem('ID de Reserva', '#${booking.id}'),
            _buildDetailItem('Servicio', booking.serviceName),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDetailItem(
                    'Fecha y Hora', 
                    DateFormat('EEEE, dd MMMM yyyy - hh:mm a', 'es_ES').format(booking.date),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio Total',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        color: mediumGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${NumberFormat('#,###').format(booking.price)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            _buildDetailItem('Dirección', booking.address),
            
            const Divider(height: 32),
            const Text(
              'Participantes',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDetailItem('Cliente', booking.clientName)),
                Expanded(child: _buildDetailItem('Proveedor', booking.providerName ?? 'No asignado')),
              ],
            ),
            
            if (booking.status == BookingStatus.cancelada && booking.cancellationReason != null)
              _buildDetailItem(
                'Motivo de Cancelación', 
                booking.cancellationReason!, 
                textColor: errorRed,
              ),
              
            if (booking.rating != null) ...[
              const Divider(height: 32),
              const Text(
                'Reseña y Calificación',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGray,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              if (booking.review != null && booking.review!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"${booking.review}"',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    color: mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    color = switch (status) {
      BookingStatus.pendiente => warningOrange,
      BookingStatus.confirmada => primaryBlue,
      BookingStatus.completada => successGreen,
      BookingStatus.cancelada => errorRed,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
              color: textColor ?? darkGray,
            ),
          ),
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
        selectedColor: primaryBlue.withValues(alpha: 0.1),
        checkmarkColor: primaryBlue,
        labelStyle: TextStyle(
          color: isSelected ? primaryBlue : mediumGray,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isSelected ? primaryBlue : Colors.transparent),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    statusColor = switch (booking.status) {
      BookingStatus.pendiente => warningOrange,
      BookingStatus.confirmada => primaryBlue,
      BookingStatus.completada => successGreen,
      BookingStatus.cancelada => errorRed,
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBookingDetails(booking);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: cardShadow, blurRadius: 10, offset: const Offset(0, 4))],
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
                    child: Icon(
                      switch (booking.status) {
                        BookingStatus.completada => Icons.check_circle_rounded,
                        BookingStatus.cancelada => Icons.cancel_rounded,
                        _ => Icons.calendar_today_rounded,
                      },
                      color: statusColor,
                    ),
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkGray),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(booking.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Proveedor: ${booking.providerName ?? 'No asignado'}',
                          style: const TextStyle(color: mediumGray, fontSize: 13),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: \$${NumberFormat('#,###').format(booking.price)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      if (booking.status == BookingStatus.pendiente || booking.status == BookingStatus.confirmada)
                        TextButton(
                          onPressed: () => _showCancelDialog(booking),
                          child: const Text('Cancelar', style: TextStyle(color: errorRed, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        ),
                      if (booking.status == BookingStatus.completada && booking.rating == null)
                        ElevatedButton(
                          onPressed: () => _showRatingDialog(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Calificar', style: TextStyle(fontSize: 12, color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                        ),
                      TextButton(
                        onPressed: () => _showBookingDetails(booking),
                        child: const Text('Detalles', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_rounded, size: 80, color: primaryBlue.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text('No hay reservas registradas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray)),
          const Text('Tus próximas reservas aparecerán aquí', style: TextStyle(color: mediumGray)),
        ],
      ),
    );
  }
}
