// Archivo: lib/screens/viaje_especialista_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 
import 'menu_especialista_screen.dart';

class ViajeEspecialistaScreen extends StatefulWidget {
  final String nombrePaciente;
  final String servicio;
  final String direccion;

  const ViajeEspecialistaScreen({
    super.key,
    required this.nombrePaciente,
    required this.servicio,
    required this.direccion,
  });

  @override
  State<ViajeEspecialistaScreen> createState() => _ViajeEspecialistaScreenState();
}

class _ViajeEspecialistaScreenState extends State<ViajeEspecialistaScreen> {
  bool _isFinishing = false;
  
  LatLng? _miUbicacionActual; 
  final LatLng _ubicacionPaciente = const LatLng(-32.8755, -71.2415); 

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionGPS(); 
  }

  Future<void> _obtenerUbicacionGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return; 

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return; 
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _miUbicacionActual = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _finalizarServicioYCobrar() async {
    setState(() => _isFinishing = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      var viajeActivo = await FirebaseFirestore.instance
          .collection('solicitudes')
          .where('especialistaId', isEqualTo: uid)
          .where('estado', isEqualTo: 'aceptado')
          .limit(1)
          .get();

      if (viajeActivo.docs.isEmpty) throw Exception("No se encontró el viaje activo");

      var docViaje = viajeActivo.docs.first;
      String precioString = docViaje['precio']; 

      String precioLimpio = precioString.replaceAll('\$', '').replaceAll('.', '');
      double precioTotal = double.parse(precioLimpio);
      double gananciaDoctor = precioTotal * 0.88;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'saldo': FieldValue.increment(gananciaDoctor),
      });

      await FirebaseFirestore.instance.collection('solicitudes').doc(docViaje.id).update({
        'estado': 'finalizado',
      });

      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MenuEspecialistaScreen()),
        (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. EL MAPA
          _miUbicacionActual == null
              ? const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text('Buscando señal GPS...', style: TextStyle(color: Colors.grey)),
                  ],
                ))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _miUbicacionActual!,
                    initialZoom: 15.0,
                    minZoom: 5.0,
                    maxZoom: 18.0, 
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tuempresa.appsalud',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _ubicacionPaciente,
                          width: 80, 
                          height: 80, 
                          child: Column(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red, size: 45),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
                                  ]
                                ),
                                child: const Text(
                                  'Destino', 
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Marker(
                          point: _miUbicacionActual!,
                          width: 60, height: 60,
                          child: Container(
                            decoration: BoxDecoration(color: colorAzul.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.directions_car, color: colorAzul, size: 35),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          // --- NUEVO: BOTÓN DE VOLVER AL MENÚ ---
          Positioned(
            top: 60, left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuEspecialistaScreen()),
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

          // 2. PANEL INFERIOR
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
                  const Text('En camino hacia el paciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: colorAzul, size: 20),
                      const SizedBox(width: 8),
                      Text(widget.direccion, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.person, color: Colors.grey, size: 30)),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.nombrePaciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('Servicio: ${widget.servicio}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(decoration: BoxDecoration(color: colorAzul.withOpacity(0.1), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.chat_bubble_outline, color: colorAzul), onPressed: () {}))
                    ],
                  ),
                  const SizedBox(height: 35),
                  ElevatedButton(
                    onPressed: _isFinishing ? null : _finalizarServicioYCobrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorNegro,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: _isFinishing
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Finalizar Servicio y Cobrar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}