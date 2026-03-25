import 'package:flutter_test/flutter_test.dart';
import 'package:servizone_app/core/services/provider_booking_service.dart';
import 'package:servizone_app/data/models/booking_model.dart';

void main() {
  late ProviderBookingService service;
  const String validProviderId = 'P1';
  const String invalidProviderId = 'P2';

  setUp(() {
    service = ProviderBookingService();
  });

  group('ProviderBookingService Tests', () {
    test('getPendingRequests filter correctly', () {
      final requests = service.getPendingRequests(validProviderId);
      expect(requests.isNotEmpty, true);
      expect(requests.every((r) => r.status == BookingStatus.pendiente), true);
      expect(requests.every((r) => r.providerId == validProviderId), true);
    });

    test('getProviderBookings filter confirmed/completed', () {
      final bookings = service.getProviderBookings(validProviderId);
      expect(bookings.isNotEmpty, true);
      expect(bookings.every((b) => b.status != BookingStatus.pendiente), true);
    });

    test('confirmRequest successful transition', () {
      final requests = service.getPendingRequests(validProviderId);
      final reqToConfirm = requests.first;
      
      final newDate = DateTime.now().add(const Duration(days: 10));
      service.confirmRequest(reqToConfirm.id, validProviderId, newDate, 'Nueva Dir 123');

      // Check it's no longer in pending
      final pendingAfter = service.getPendingRequests(validProviderId);
      expect(pendingAfter.any((r) => r.id == reqToConfirm.id), false);

      // Check it's in bookings as confirmed
      final bookingsAfter = service.getProviderBookings(validProviderId);
      final confirmedBooking = bookingsAfter.firstWhere((b) => b.id == reqToConfirm.id);
      expect(confirmedBooking.status, equals(BookingStatus.confirmada));
      expect(confirmedBooking.address, equals('Nueva Dir 123'));
    });

    test('confirmRequest throws error if providerId does not match', () {
      final requests = service.getPendingRequests(validProviderId);
      final reqToConfirm = requests.first;
      
      expect(
        () => service.confirmRequest(reqToConfirm.id, invalidProviderId, DateTime.now(), 'Dir'),
        throwsException
      );
    });

    test('rejectRequest successful transition with reason', () {
      final requests = service.getPendingRequests(validProviderId);
      final reqToReject = requests.first;
      
      service.rejectRequest(reqToReject.id, validProviderId, 'No tengo tiempo');

      // Check it's no longer in pending
      final pendingAfter = service.getPendingRequests(validProviderId);
      expect(pendingAfter.any((r) => r.id == reqToReject.id), false);

      // Check it's in bookings as rechazada
      final bookingsAfter = service.getProviderBookings(validProviderId);
      final rejectedBooking = bookingsAfter.firstWhere((b) => b.id == reqToReject.id);
      expect(rejectedBooking.status, equals(BookingStatus.rechazada));
      expect(rejectedBooking.cancellationReason, equals('No tengo tiempo'));
    });

    test('rejectRequest throws error if reason is empty', () {
      final requests = service.getPendingRequests(validProviderId);
      final reqToReject = requests.first;
      
      expect(
        () => service.rejectRequest(reqToReject.id, validProviderId, '  '),
        throwsException
      );
    });
  });
}
