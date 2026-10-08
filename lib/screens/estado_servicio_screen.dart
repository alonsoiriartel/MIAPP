// Archivo: lib/screens/estado_servicio_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'viaje_paciente_screen.dart'; 
import 'menu_paciente_screen.dart'; // <-- IMPORTANTE: Lo necesitamos para poder volver

class EstadoServicioScreen extends StatelessWidget {
  final String tituloServicio;

  const EstadoServicioScreen({super.key, required this.tituloServicio});

  @override
  Widget build(BuildContext context) {
    const colorAzul = Color(0xFF2F65F6);
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      // --- 1. AÑADIMOS EL BOTÓN DE ATRÁS ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // Regresa al menú sin cancelar (El banner verde aparecerá)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuPacienteScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitudes')
            .where('pacienteId', isEqualTo: uid)
            .where('estado', whereIn: ['buscando', 'aceptado']) // Escucha solo las activas
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.hasError) {
            return Center(child: Text('Error de conexión: ${snapshot.error}', textAlign: TextAlign.center));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: colorAzul));
          }

          // Si el usuario acaba de cancelar, el documento desaparece. Mostramos esto un milisegundo antes de cambiar de pantalla.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Servicio cancelado...', style: TextStyle(color: Colors.grey)));
          }

          var doc = snapshot.data!.docs.first;
          var datos = doc.data() as Map<String, dynamic>;
          String estado = datos['estado'];
          String docId = doc.id; // Necesitamos el ID para poder borrarlo si cancela

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: estado == 'aceptado' ? Colors.green[50] : colorAzul.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      estado == 'aceptado' ? Icons.check_circle : Icons.radar,
                      size: 80,
                      color: estado == 'aceptado' ? Colors.green : colorAzul,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Text(
                    estado == 'aceptado' 
                      ? '¡Especialista en camino!' 
                      : 'Buscando especialista en\n$tituloServicio...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  Text(
                    estado == 'aceptado'
                      ? 'El profesional ha aceptado tu solicitud.'
                      : 'Notificando a los profesionales cercanos',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 50),

                  // --- 2. LOS BOTONES DINÁMICOS ---
                  if (estado == 'aceptado') 
                    // BOTÓN: IR AL MAPA (Solo si ya aceptaron)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ViajePacienteScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Ver ubicación del especialista', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  else
                    // BOTÓN: CANCELAR BÚSQUEDA (Solo si sigue buscando)
                    OutlinedButton(
                      onPressed: () async {
                        // 1. Borramos la solicitud de la base de datos
                        await FirebaseFirestore.instance.collection('solicitudes').doc(docId).delete();
                        
                        if (!context.mounted) return;
                        
                        // 2. Lo devolvemos al menú limpio
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuPacienteScreen()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.withOpacity(0.3)),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Cancelar Búsqueda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}