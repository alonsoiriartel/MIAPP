// Archivo: lib/screens/menu_paciente_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pago_screen.dart';
import 'historial_screen.dart';
import 'perfil_screen.dart';
import 'viaje_paciente_screen.dart';
import 'estado_servicio_screen.dart';

class MenuPacienteScreen extends StatefulWidget {
  const MenuPacienteScreen({super.key});

  @override
  State<MenuPacienteScreen> createState() => _MenuPacienteScreenState();
}

class _MenuPacienteScreenState extends State<MenuPacienteScreen> {
  int _indicePestanaActual = 0; 

  @override
  Widget build(BuildContext context) {
    const colorAzul = Color(0xFF2F65F6);
    const colorGris = Color(0xFFB1B1B1);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _indicePestanaActual == 0
            ? _construirPanelPrincipal()
            : _indicePestanaActual == 1
                ? const HistorialScreen()
                : const PerfilScreen(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: colorAzul, 
          unselectedItemColor: colorGris, 
          currentIndex: _indicePestanaActual,
          onTap: (index) {
            setState(() { _indicePestanaActual = index; });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 30), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.access_time_filled, size: 30), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _construirPanelPrincipal() {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const Center(child: Text('Error: Sesión no encontrada'));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('Cargando perfil...'));

        var datos = snapshot.data!.data() as Map<String, dynamic>;
        String nombreReal = datos['nombre'] ?? 'Paciente';
        String primerNombre = nombreReal.split(' ')[0];

        // --- LA SOLUCIÓN DEL SCROLL ---
        // Forzamos el scroll incluso si los elementos no llenan la pantalla
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0, bottom: 40.0), // Margen inferior añadido
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('¡Hola, $primerNombre!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.grey, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('solicitudes')
                    .where('pacienteId', isEqualTo: uid)
                    .where('estado', whereIn: ['buscando', 'aceptado']) 
                    .snapshots(),
                builder: (context, snapshotViaje) {
                  if (snapshotViaje.hasData && snapshotViaje.data!.docs.isNotEmpty) {
                    var viaje = snapshotViaje.data!.docs.first.data() as Map<String, dynamic>;
                    bool aceptado = viaje['estado'] == 'aceptado';

                    return GestureDetector(
                      onTap: () {
                        if (aceptado) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ViajePacienteScreen()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EstadoServicioScreen(tituloServicio: viaje['servicio'])));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorAzul.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorAzul.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.map, color: colorAzul),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Servicio en curso', style: TextStyle(fontWeight: FontWeight.bold, color: colorAzul)),
                                  Text(aceptado ? 'Tu especialista va en camino' : 'Buscando profesional...', style: const TextStyle(fontSize: 13, color: colorAzul)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: colorAzul, size: 16),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); 
                },
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué especialista necesitas hoy?',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: colorAzul),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              const SizedBox(height: 35),

              const Text('Especialidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorNegro)),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _crearTarjetaServicio('Kinesiología', Icons.accessibility_new, colorAzul, '\$30.000')),
                  const SizedBox(width: 15),
                  Expanded(child: _crearTarjetaServicio('Enfermería', Icons.medical_services, const Color(0xFF28A745), '\$25.000')),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _crearTarjetaServicio('Psicología', Icons.psychology, Colors.purple, '\$35.000')),
                  const SizedBox(width: 15),
                  Expanded(child: _crearTarjetaServicio('Nutrición', Icons.restaurant_menu, Colors.orange, '\$20.000')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _crearTarjetaServicio(String titulo, IconData icono, Color colorIcono, String precioBase) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorIcono.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icono, color: colorIcono, size: 30),
          ),
          const SizedBox(height: 20),
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('Desde $precioBase', style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PagoScreen(servicio: titulo, precio: precioBase)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text('Solicitar', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}