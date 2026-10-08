// Archivo: lib/screens/viaje_paciente_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'menu_paciente_screen.dart';

class ViajePacienteScreen extends StatelessWidget {
  const ViajePacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitudes')
            .where('pacienteId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.hasError) return Center(child: Text('Error de conexión: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Buscando ruta...'));

          try {
            var documentos = snapshot.data!.docs.toList();
            documentos.sort((a, b) {
              Timestamp fechaA = (a.data() as Map<String, dynamic>)['fecha'] ?? Timestamp.now();
              Timestamp fechaB = (b.data() as Map<String, dynamic>)['fecha'] ?? Timestamp.now();
              return fechaB.compareTo(fechaA); 
            });

            var viajeMasReciente = documentos.first.data() as Map<String, dynamic>;
            String estado = viajeMasReciente['estado'] ?? '';

            if (estado == 'finalizado') {
              return _construirRecibo(context, viajeMasReciente);
            } else {
              return _construirMapaViaje(context);
            }
          } catch (e) {
            return Center(child: Text('Error al cargar la interfaz: $e'));
          }
        },
      ),
    );
  }

  Widget _construirMapaViaje(BuildContext context) {
    const colorAzul = Color(0xFF2F65F6);
    final LatLng ubicacionDestino = const LatLng(-32.8755, -71.2415); 

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: ubicacionDestino,
            initialZoom: 16.0,
          ),
          children: [
            TileLayer(
              // NUEVO ESTILO DE MAPA: Minimalista y claro
              urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tuempresa.appsalud',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: ubicacionDestino,
                  width: 60, height: 60,
                  child: const Icon(Icons.location_on, color: colorAzul, size: 50),
                ),
              ],
            ),
          ],
        ),
        
        Positioned(
          top: 60, left: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MenuPacienteScreen()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            ),
          ),
        ),

        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 25),
                const Text('El profesional va en camino', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Llegada estimada: 15 min', style: TextStyle(color: colorAzul, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle), child: const Icon(Icons.medical_services, color: Colors.grey, size: 30)),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tu Especialista', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('En camino', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirRecibo(BuildContext context, Map<String, dynamic> datos) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 30),
          const Text('¡Servicio Completado!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorNegro)),
          const SizedBox(height: 15),
          const Text('El especialista ha finalizado la atención.\nEl cobro se ha realizado con éxito.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Servicio', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text(datos['servicio'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total pagado', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    Text(datos['precio'] ?? '', style: const TextStyle(color: colorAzul, fontWeight: FontWeight.bold, fontSize: 22)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MenuPacienteScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorNegro,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Volver al Inicio', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}