import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Función para Guardar un Nuevo Usuario (Registro)
  Future<void> guardarUsuarioNuevo(UsuarioModel usuario) async {
    try {
      await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
      print("Usuario guardado correctamente en Firestore");
    } catch (e) {
      print("Error al guardar usuario: $e");
      throw e;
    }
  }

  // 2. Función para Leer los Datos del Usuario (Inicio de Sesión)
  Future<UsuarioModel?> obtenerDatosUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(uid).get();
      
      if (doc.exists) {
        return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        print("El documento no existe");
        return null;
      }
    } catch (e) {
      print("Error al obtener datos: $e");
      return null;
    }
  }

  // 3. Función para Actualizar el estado KYC (Verificación)
  Future<void> actualizarEstadoVerificacion(String uid, bool estado) async {
    try {
      await _db.collection('usuarios').doc(uid).update({
        'kyc_verificado': estado,
      });
      print("Estado KYC actualizado a $estado");
    } catch (e) {
      print("Error al actualizar KYC: $e");
    }
  }
}