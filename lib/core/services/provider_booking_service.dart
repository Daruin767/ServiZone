import 'package:flutter/foundation.dart';
import 'package:servizone_app/data/models/booking_model.dart';
import 'package:servizone_app/core/services/booking_filter_service.dart';

class ProviderBookingService extends ChangeNotifier {
  // Simulating a database with in-memory data
  final List<BookingModel> _bookings = [
    BookingModel(
      id: 'req1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Juan Pérez',
      serviceType: 'Plomería',
      serviceName: 'Fuga de agua',
      date: DateTime.now().add(const Duration(days: 1)),
      address: 'Calle 123 # 45-67',
      price: 45000,
      status: BookingStatus.pendiente,
    ),
    BookingModel(
      id: 'req2',
      clientId: 'C2',
      providerId: 'P1',
      clientName: 'María López',
      serviceType: 'Electricidad',
      serviceName: 'Instalación',
      date: DateTime.now().add(const Duration(days: 2)),
      address: 'Carrera 10 # 20-30',
      price: 60000,
      status: BookingStatus.pendiente,
    ),
    BookingModel(
      id: 'req3',
      clientId: 'C3',
      providerId: 'P1',
      clientName: 'Carlos Ruiz',
      serviceType: 'Limpieza',
      serviceName: 'Express',
      date: DateTime.now().add(const Duration(days: 3)),
      address: 'Avenida 5 # 15-25',
      price: 35000,
      status: BookingStatus.pendiente,
    ),
    BookingModel(
      id: 'book1',
      clientId: 'C1',
      providerId: 'P1',
      clientName: 'Ana García',
      serviceType: 'Plomería',
      serviceName: 'Fuga de agua',
      date: DateTime.now().add(const Duration(days: 2)),
      address: 'Calle 100 # 20-30',
      price: 45000,
      status: BookingStatus.confirmada,
    ),
    BookingModel(
      id: 'book3',
      clientId: 'C3',
      providerId: 'P1',
      clientName: 'Luis Rodríguez',
      serviceType: 'Limpieza',
      serviceName: 'Hogar',
      date: DateTime.now().subtract(const Duration(days: 15)),
      address: 'Calle 80 # 40-50',
      price: 80000,
      status: BookingStatus.completada,
      rating: 4.8,
      review: 'Muy buen trabajo, recomendado.',
    ),
  ];

  // Métodos para REQUERIMIENTOS: Obtener solicitudes pendientes
  List<BookingModel> getPendingRequests(String providerId, {String query = '', DateTime? date, String? serviceName}) {
    return _bookings.where((b) {
      if (b.status != BookingStatus.pendiente) return false;
      if (b.providerId != providerId) return false;
      
      final nameMatch = b.clientName.toLowerCase().contains(query.toLowerCase());
      final dateMatch = date == null || 
          (b.date.year == date.year && 
           b.date.month == date.month && 
           b.date.day == date.day);
      final serviceMatch = serviceName == null || b.serviceName == serviceName;
      
      return nameMatch && dateMatch && serviceMatch;
    }).toList();
  }

  // Métodos para REQUERIMIENTOS: Obtener reservas del proveedor (no pendientes) filtradas por rango de meses, estado y búsqueda
  List<BookingModel> getProviderBookings(String providerId, {BookingStatus? statusFilter, int monthsFilter = 1, String query = ''}) {
    final now = DateTime.now();
    final filterDate = now.subtract(Duration(days: monthsFilter * 30));
    
    return _bookings.where((booking) {
      if (booking.providerId != providerId) return false;
      if (booking.status == BookingStatus.pendiente) return false; // Not a reservation yet
      
      final dateMatch = booking.date.isAfter(filterDate);
      final statusMatch = statusFilter == null || booking.status == statusFilter;
      final queryMatch = query.isEmpty || 
          booking.clientName.toLowerCase().contains(query.toLowerCase()) ||
          booking.serviceName.toLowerCase().contains(query.toLowerCase());
      
      return dateMatch && statusMatch && queryMatch;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  // Extra para reuso global
  List<String> getProviderServiceNames(String providerId) {
    return _bookings
        .where((b) => b.providerId == providerId)
        .map((b) => b.serviceName)
        .toSet()
        .toList();
  }

  // Acción: Aceptar Solicitud
  void confirmRequest(String bookingId, String providerId, DateTime newDate, String newAddress) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Solicitud no encontrada');
    
    if (_bookings[index].providerId != providerId) {
      throw Exception('Autorización denegada: Solo puedes modificar tus propias solicitudes');
    }

    _bookings[index] = _bookings[index].copyWith(
      status: BookingStatus.confirmada,
      date: newDate,
      address: newAddress,
    );
    
    // Log de auditoría requerido
    print('AUDITORÍA [${DateTime.now().toIso8601String()}]: Solicitud $bookingId CONFIRMADA por proveedor $providerId. Datos actualizados: Fecha $newDate, Dirección $newAddress.');
    
    notifyListeners();
  }

  // Acción: Rechazar Solicitud
  void rejectRequest(String bookingId, String providerId, String reason) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Solicitud no encontrada');
    
    if (_bookings[index].providerId != providerId) {
      throw Exception('Autorización denegada: Solo puedes modificar tus propias solicitudes');
    }

    if (reason.trim().isEmpty) {
      throw Exception('El motivo de rechazo es obligatorio');
    }

    _bookings[index] = _bookings[index].copyWith(
      status: BookingStatus.rechazada,
      cancellationReason: reason,
    );

    // Log de auditoría requerido
    print('AUDITORÍA [${DateTime.now().toIso8601String()}]: Solicitud $bookingId RECHAZADA por proveedor $providerId. Motivo: $reason.');
    
    notifyListeners();
  }
  
  void completeBooking(String bookingId, String providerId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Reserva no encontrada');
    
    if (_bookings[index].providerId != providerId) {
      throw Exception('Autorización denegada: Solo puedes modificar tus propias reservas');
    }

    _bookings[index] = _bookings[index].copyWith(
      status: BookingStatus.completada,
    );

    // Log de auditoría requerido
    print('AUDITORÍA [${DateTime.now().toIso8601String()}]: Reserva $bookingId COMPLETADA por proveedor $providerId.');
    
    notifyListeners();
  }
}
