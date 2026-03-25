import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servizone_app/core/locator.dart';
import 'package:servizone_app/core/services/provider_booking_service.dart';
import 'package:servizone_app/presentation/views/provider/provider_requests_view.dart';
import 'package:servizone_app/data/models/booking_model.dart';

void main() {
  setUpAll(() {
    locator.registerLazySingleton<ProviderBookingService>(() => ProviderBookingService());
  });

  tearDownAll(() {
    locator.reset();
  });

  testWidgets('Provider requests flow: Confirm a request and it disappears from list', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: ProviderRequestsView(),
      ),
    );

    // Initial state: Should see some requests (e.g. "Plomería - Fuga de agua")
    expect(find.text('Plomería - Fuga de agua'), findsOneWidget);

    // Find the Aceptar button for the first request
    final acceptButton = find.widgetWithText(ElevatedButton, 'Aceptar').first;
    expect(acceptButton, findsOneWidget);

    // Tap to accept
    await tester.tap(acceptButton);
    await tester.pumpAndSettle();

    // Dialog appears, has "Confirmar Reserva" title
    expect(find.text('Confirmar Reserva'), findsWidgets);

    // Find the Confirmar Reserva sub-button in dialog
    final confirmDialogButton = find.widgetWithText(ElevatedButton, 'Confirmar Reserva').last;
    
    // Tap confirm inside dialog
    await tester.tap(confirmDialogButton);
    await tester.pumpAndSettle();

    // Snackbar might appear, dialogue vanishes
    expect(find.byType(AlertDialog), findsNothing);
    
    // Verify it was removed from the list (actually we have multiple so let's just assert service state)
    final service = locator<ProviderBookingService>();
    final pending = service.getPendingRequests('P1');
    
    // Original mock data has 3 pending. We removed 1, so 2 remaining.
    expect(pending.length, equals(2));
  });
}
