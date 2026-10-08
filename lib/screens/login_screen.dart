// Archivo: lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'registro_screen.dart';
import 'menu_paciente_screen.dart';
import 'menu_especialista_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _esPaciente = true; 
  bool _isLoading = false; 

  Future<void> _iniciarSesion() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _mostrarMensaje('Por favor, ingresa tu correo y contraseña');
      return;
    }

    setState(() { _isLoading = true; }); 

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;
      
      if (doc.exists) {
        String rolBD = doc.get('rol').toString().toLowerCase();
        String rolUI = _esPaciente ? 'paciente' : 'especialista';

        // --- LA NUEVA VALIDACIÓN DE SEGURIDAD ---
        if (rolBD != rolUI) {
          // Si intentan cruzar cuentas, los deslogueamos inmediatamente
          await FirebaseAuth.instance.signOut();
          _mostrarMensaje('Error: Esta cuenta pertenece a un ${rolBD.toUpperCase()}. Por favor cambia de pestaña.');
          setState(() { _isLoading = false; });
          return;
        }

        if (rolBD == 'paciente') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuPacienteScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuEspecialistaScreen()));
        }
      } else {
        _mostrarMensaje('Error: No se encontraron los datos del perfil');
      }

    } on FirebaseAuthException catch (e) {
      String mensajeError = 'Ocurrió un error al iniciar sesión';
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        mensajeError = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo no es válido.';
      } else if (e.code == 'too-many-requests') {
         mensajeError = 'Demasiados intentos. Intenta más tarde.';
      }
      _mostrarMensaje(mensajeError);
    } catch (e) {
      _mostrarMensaje('Ocurrió un error inesperado');
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; }); 
      }
    }
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);
    const colorGris = Color(0xFFB1B1B1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.health_and_safety, size: 60, color: colorAzul),
              ),
              const SizedBox(height: 40),

              const Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              const Text('Inicia sesión para continuar', style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined, color: colorGris),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline, color: colorGris),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: colorAzul, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esPaciente = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _esPaciente ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: _esPaciente ? [const BoxShadow(color: Colors.black12, blurRadius: 5)] : [],
                          ),
                          child: Center(child: Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold, color: _esPaciente ? colorNegro : Colors.grey))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _esPaciente = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_esPaciente ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: !_esPaciente ? [const BoxShadow(color: Colors.black12, blurRadius: 5)] : [],
                          ),
                          child: Center(child: Text('Especialista', style: TextStyle(fontWeight: FontWeight.bold, color: !_esPaciente ? colorNegro : Colors.grey))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              ElevatedButton(
                onPressed: _isLoading ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorNegro,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Entrar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroScreen())),
                    child: const Text('Regístrate', style: TextStyle(color: colorAzul, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}