// Archivo: test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mi_app/main.dart'; // Asumiendo que tu proyecto se llama mi_app

void main() {
  testWidgets('Prueba de arranque de la aplicación', (WidgetTester tester) async {
    // 1. Construye nuestra aplicación y activa el primer frame (la Splash Screen)
    await tester.pumpWidget(const MyApp());

    // 2. Verifica que el texto de la pantalla de carga existe
    expect(find.text('Cargando tu bienestar...'), findsOneWidget);
    
    // 3. Verifica que el spinner de carga está en pantalla
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}