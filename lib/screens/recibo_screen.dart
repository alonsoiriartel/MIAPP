// Archivo: lib/recibo_screen.dart
import 'package:flutter/material.dart';
import 'menu_paciente_screen.dart'; // Para poder regresar al inicio

class ReciboScreen extends StatelessWidget {
  final String tituloServicio;
  final String precioServicio;

  const ReciboScreen({
    super.key,
    required this.tituloServicio,
    required this.precioServicio,
  });

  @override
  Widget build(BuildContext context) {
    const colorAzul = Color(0xFF2F65F6);
    const colorVerde = Color(0xFF28A745);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido
                children: [
                  // Círculo Verde con Check
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: colorVerde,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 55),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    '¡Atención finalizada!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorVerde),
                  ),
                  const SizedBox(height: 25),

                  // Detalles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Servicio: ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      Icon(Icons.vaccines, color: colorAzul, size: 18), // Ícono de ejemplo
                      Text(' $tituloServicio', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Especialista: Juan Kinesiólogo',
                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pago liberado: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(precioServicio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorVerde)),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Botón Volver al Inicio
                  ElevatedButton(
                    onPressed: () {
                      // Esto borra todo el historial de navegación y te deja limpio en el Menú Principal
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MenuPacienteScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorAzul,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text('Volver al Inicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),

                  // Enlace Descargar boleta
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Descargar boleta',
                      style: TextStyle(color: colorAzul, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}