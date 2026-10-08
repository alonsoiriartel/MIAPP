// Archivo: lib/screens/menu_especialista_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'viaje_especialista_screen.dart';
import 'ganancias_screen.dart';
import 'perfil_screen.dart';

class MenuEspecialistaScreen extends StatefulWidget {
  const MenuEspecialistaScreen({super.key});

  @override
  State<MenuEspecialistaScreen> createState() => _MenuEspecialistaScreenState();
}

class _MenuEspecialistaScreenState extends State<MenuEspecialistaScreen> {
  bool _isOnline = false;
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
                ? const GananciasScreen() 
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
            setState(() {
              _indicePestanaActual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard, size: 30), label: 'Panel'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet, size: 30), label: 'Ganancias'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 30), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _construirPanelPrincipal() {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);
    const colorVerde = Color(0xFF28A745);

    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const Center(child: Text('Error: Sesión no encontrada'));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Cargando perfil...'));
        }

        var datos = snapshot.data!.data() as Map<String, dynamic>;
        String nombreReal = datos['nombre'] ?? 'Doctor';
        String especialidadReal = datos['especialidad'] ?? 'Especialista';
        String nombreCorto = nombreReal.split(' ')[0];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Hola, $nombreCorto!', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text(especialidadReal, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.grey, size: 30),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- NUEVO: BANNER DE VIAJE ACTIVO PARA EL ESPECIALISTA ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('solicitudes')
                    .where('especialistaId', isEqualTo: uid)
                    .where('estado', isEqualTo: 'aceptado') 
                    .snapshots(),
                builder: (context, snapshotViaje) {
                  if (snapshotViaje.hasData && snapshotViaje.data!.docs.isNotEmpty) {
                    var viaje = snapshotViaje.data!.docs.first.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        // Navega enviando los datos de Firestore de vuelta al mapa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViajeEspecialistaScreen(
                              nombrePaciente: viaje['pacienteNombre'] ?? 'Paciente',
                              servicio: viaje['servicio'] ?? 'Servicio',
                              direccion: viaje['direccion'] ?? 'Dirección',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 25),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: colorVerde.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colorVerde.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.directions_car, color: colorVerde),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Servicio en curso', style: TextStyle(fontWeight: FontWeight.bold, color: colorVerde)),
                                  Text('Toca para volver al mapa', style: TextStyle(fontSize: 13, color: colorVerde)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: colorVerde, size: 16),
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
                  color: _isOnline ? colorAzul : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isOnline ? 'Estás en línea' : 'Estás desconectado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isOnline ? Colors.white : colorNegro)),
                        const SizedBox(height: 4),
                        Text(_isOnline ? 'Buscando pacientes cercanos...' : 'Conéctate para recibir servicios', style: TextStyle(fontSize: 13, color: _isOnline ? Colors.white70 : Colors.grey)),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      activeColor: Colors.white,
                      activeTrackColor: colorVerde,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[200],
                      onChanged: (value) => setState(() => _isOnline = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text('Solicitudes entrantes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorNegro)),
              const SizedBox(height: 15),

              Expanded(
                child: _isOnline 
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('solicitudes')
                          .where('estado', isEqualTo: 'buscando')
                          .where('servicio', isEqualTo: especialidadReal)
                          .snapshots(),
                      builder: (context, snapshotRequest) {
                        
                        if (snapshotRequest.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshotRequest.hasData || snapshotRequest.data!.docs.isEmpty) {
                          return Center(
                            child: Text('No hay solicitudes cercanas de $especialidadReal en este momento.', 
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500]))
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: snapshotRequest.data!.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshotRequest.data!.docs[index];
                            var datosSolicitud = doc.data() as Map<String, dynamic>;
                            
                            return _crearTarjetaSolicitud(
                              doc.id,
                              datosSolicitud['pacienteNombre'] ?? 'Paciente',
                              datosSolicitud['servicio'] ?? 'Servicio',
                              datosSolicitud['direccion'] ?? 'Dirección',
                              datosSolicitud['precio'] ?? '\$0',
                              colorAzul, 
                              colorVerde
                            );
                          },
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bedtime_outlined, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 15),
                          Text('No estás recibiendo solicitudes', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        );
      },
    ); 
  }

  Widget _crearTarjetaSolicitud(String docId, String paciente, String servicio, String direccion, String precio, Color colorAzul, Color colorVerde) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: colorAzul.withOpacity(0.1), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nueva solicitud', style: TextStyle(color: colorAzul, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(precio, style: TextStyle(color: colorVerde, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paciente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(servicio, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(height: 1, color: Color(0xFFEEEEEE))),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 16),
              const SizedBox(width: 5),
              Text(direccion, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Rechazar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('solicitudes')
                        .doc(docId)
                        .update({
                      'estado': 'aceptado',
                      'especialistaId': FirebaseAuth.instance.currentUser!.uid,
                    });

                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViajeEspecialistaScreen(
                          nombrePaciente: paciente,
                          servicio: servicio,
                          direccion: direccion,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}