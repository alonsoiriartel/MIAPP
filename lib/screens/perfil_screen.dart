// Archivo: lib/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Importante para poder volver al inicio

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // --- LA LLAVE DE SALIDA ---
  Future<void> _cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    
    if (!context.mounted) return;
    // Borramos todo el historial de navegación y volvemos al Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    const colorNegro = Color(0xFF000000);

    if (uid == null) return const Center(child: Text('Error: Sesión no encontrada'));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Cargando perfil...'));
            }

            // Extraemos los datos del usuario actual
            var datos = snapshot.data!.data() as Map<String, dynamic>;
            String nombre = datos['nombre'] ?? 'Usuario';
            String correo = datos['correo'] ?? 'correo@ejemplo.com';
            String rol = datos['rol'] ?? 'Rol no definido';

            return Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text('Mi Perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
                  const SizedBox(height: 40),
                  
                  // Avatar visual
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.person, color: Colors.grey, size: 50),
                  ),
                  const SizedBox(height: 25),
                  
                  // Información de la Base de Datos
                  Text(nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(correo, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 15),
                  
                  // Etiqueta de Rol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: rol == 'Especialista' ? Colors.blue[50] : Colors.purple[50], 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      rol.toUpperCase(), 
                      style: TextStyle(
                        color: rol == 'Especialista' ? Colors.blue[700] : Colors.purple[700], 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12
                      )
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // BOTÓN DE CERRAR SESIÓN
                  ElevatedButton.icon(
                    onPressed: () => _cerrarSesion(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}