import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:servizone_app/main.dart';

void main() {
  testWidgets('ServiZone splash screen test', (WidgetTester tester) async {
    // Construir la app
    await tester.pumpWidget(const ServiZoneApp()); // 👈 Cambiado de MyApp a ServiZoneApp
    
    // Verificar que el texto "ServiZone" aparece
    expect(find.text('ServiZone'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
