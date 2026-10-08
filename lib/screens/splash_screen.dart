// Archivo: lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; 
import 'login_screen.dart'; 
import 'menu_paciente_screen.dart';
import 'menu_especialista_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesion(); // <-- Arrancamos la verificación
  }

  Future<void> _verificarSesion() async {
    // 1. Dejamos tu animación de 2.5 segundos para que se vea premium
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    User? usuarioActual = FirebaseAuth.instance.currentUser;

    if (usuarioActual != null) {
      // 2. Si hay una sesión guardada, buscamos su rol en Firestore
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('usuarios').doc(usuarioActual.uid).get();
        if (doc.exists && mounted) {
          String rol = doc.get('rol').toString().toLowerCase();
          
          if (rol == 'paciente') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MenuPacienteScreen()));
            return;
          } else if (rol == 'especialista') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MenuEspecialistaScreen()));
            return;
          }
        }
      } catch (e) {
        print("Error leyendo perfil en el Splash: $e");
      }
    }
    
    // 3. Si no hay sesión, o hubo un error, vamos al Login con el efecto suave
    if (mounted) {
      Navigator.of(context).pushReplacement(_crearRutaFade(const LoginScreen()));
    }
  }

  Route _crearRutaFade(Widget destino) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => destino,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut;
        var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        return FadeTransition(opacity: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    const colorAzul = Color(0xFF2F65F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 15))],
              ),
              child: const Icon(Icons.health_and_safety, size: 70, color: colorAzul),
            ),
            const SizedBox(height: 30),
            Text('Cargando tu bienestar...', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 50),
            const SizedBox(
              width: 25, height: 25,
              child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(colorAzul)),
            ),
          ],
        ),
      ),
    );
  }
}