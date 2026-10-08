// Archivo: lib/screens/registro_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario_model.dart';
import '../services/database_service.dart';
import 'menu_paciente_screen.dart';
import 'menu_especialista_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  
  String _tipoUsuario = 'Paciente';
  String? _especialidad; // Nueva variable para guardar la especialidad elegida
  bool _isLoading = false; 

  // Lista de especialidades disponibles
  final List<String> _listaEspecialidades = [
    'Kinesiología',
    'Terapia Respiratoria',
    'Enfermería',
    'Medicina General',
    'Psicología'
  ];

  Future<void> _crearCuentaFirebase() async {
    // 1. Validaciones
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nombreController.text.isEmpty) {
      _mostrarMensaje('Por favor, llena todos los campos de texto');
      return;
    }

    // Validación extra: Si es especialista, DEBE elegir especialidad
    if (_tipoUsuario == 'Especialista' && _especialidad == null) {
      _mostrarMensaje('Por favor, selecciona tu especialidad médica');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // 2. Crear credenciales en Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 3. Crear el objeto con nuestro Modelo
      // Nota: Tu diseño no pide teléfono por ahora, así que enviamos un texto vacío
      UsuarioModel perfilNuevo = UsuarioModel(
        uid: userCredential.user!.uid,
        nombre: _nombreController.text.trim(),
        correo: _emailController.text.trim(),
        telefono: '', 
        rol: _tipoUsuario.toLowerCase(), // Guardamos 'paciente' o 'especialista' en minúsculas
        fechaRegistro: DateTime.now(),
        profesion: _tipoUsuario == 'Especialista' ? _especialidad : null,
      );

      // 4. Guardar la ficha usando nuestro Servicio centralizado
      DatabaseService db = DatabaseService();
      await db.guardarUsuarioNuevo(perfilNuevo);

      if (!mounted) return;
      
      // 5. Navegación
      if (_tipoUsuario == 'Paciente') {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MenuPacienteScreen()), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MenuEspecialistaScreen()), (route) => false);
      }

    } on FirebaseAuthException catch (e) {
      // Errores de la contraseña/correo
      String mensajeError = 'Error de autenticación: ${e.message}';
      if (e.code == 'weak-password') mensajeError = 'La contraseña es muy débil (mínimo 6 caracteres).';
      if (e.code == 'email-already-in-use') mensajeError = 'Este correo ya está registrado.';
      _mostrarMensaje(mensajeError);
    } catch (e) {
      _mostrarMensaje('Ocurrió un error inesperado: $e');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
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
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text('Crear cuenta', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
              const SizedBox(height: 10),
              const Text('Únete a la nueva era de la salud a domicilio.', style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),

              // 1. Selector de tipo de usuario
              Container(
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _tipoUsuario,
                    icon: const Icon(Icons.keyboard_arrow_down, color: colorNegro),
                    items: ['Paciente', 'Especialista'].map((String valor) {
                      return DropdownMenuItem<String>(value: valor, child: Text('Soy $valor', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)));
                    }).toList(),
                    onChanged: (String? nuevoValor) {
                      setState(() {
                        if (nuevoValor != null) {
                          _tipoUsuario = nuevoValor;
                          // Si vuelve a ser Paciente, borramos la especialidad
                          if (_tipoUsuario == 'Paciente') _especialidad = null;
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. EL NUEVO SELECTOR DE ESPECIALIDAD (Solo aparece si es Especialista)
              if (_tipoUsuario == 'Especialista') ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50], // Un color sutil para destacarlo
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3))
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Elige tu especialidad médica', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                      value: _especialidad,
                      icon: const Icon(Icons.medical_services, color: Colors.blue),
                      items: _listaEspecialidades.map((String valor) {
                        return DropdownMenuItem<String>(value: valor, child: Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)));
                      }).toList(),
                      onChanged: (String? nuevoValor) {
                        setState(() { _especialidad = nuevoValor; });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Campo de Nombre
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Correo
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña (mínimo 6 caracteres)',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 40),

              // Botón Registrarme
              ElevatedButton(
                onPressed: _isLoading ? null : _crearCuentaFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorNegro,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('Registrarme', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}