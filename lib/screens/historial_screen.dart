// Archivo: lib/historial_screen.dart
import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);
    const colorVerde = Color(0xFF28A745);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Título de la sección
          const Text(
            'Mi actividad',
            style: TextStyle(
              fontSize: 26, 
              fontWeight: FontWeight.bold, 
              color: colorNegro, 
              letterSpacing: -0.5
            ),
          ),
          const SizedBox(height: 30),
          
          // Lista de atenciones pasadas
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _crearTarjetaHistorial('Inyección', 'Juan Kinesiólogo', '12 de Octubre, 2026', '\$15.000', colorAzul, colorVerde),
                const SizedBox(height: 20),
                _crearTarjetaHistorial('Evaluación Nutricional', 'María Nutricionista', '05 de Octubre, 2026', '\$20.000', colorAzul, colorVerde),
                const SizedBox(height: 20),
                _crearTarjetaHistorial('Terapia Respiratoria', 'Pedro Kinesiólogo', '28 de Septiembre, 2026', '\$25.000', colorAzul, colorVerde),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Constructor visual de las tarjetas del historial
  Widget _crearTarjetaHistorial(String servicio, String especialista, String fecha, String precio, Color colorAzul, Color colorVerde) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: Fecha y Etiqueta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fecha, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: colorVerde.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Text('Completado', style: TextStyle(color: Color(0xFF28A745), fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Fila inferior: Ícono, Textos y Precio
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: colorAzul.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.medical_services, color: colorAzul, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(servicio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(especialista, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              Text(precio, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}