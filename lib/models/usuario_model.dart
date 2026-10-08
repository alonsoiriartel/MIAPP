import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nombre;
  final String correo;
  final String telefono;
  final String rol; // 'paciente' o 'especialista'
  final DateTime fechaRegistro;

  // Campos exclusivos para Especialistas
  final String? profesion;
  final int? tarifa;
  final bool kycVerificado;
  final bool serviciosActivos;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.fechaRegistro,
    this.profesion,
    this.tarifa,
    this.kycVerificado = false,
    this.serviciosActivos = true,
  });

  // Convertir de Firestore a Dart
  factory UsuarioModel.fromMap(Map<String, dynamic> data, String id) {
    return UsuarioModel(
      uid: id,
      nombre: data['nombre'] ?? '',
      correo: data['correo'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: data['rol'] ?? 'paciente',
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      profesion: data['profesion'],
      tarifa: data['tarifa'],
      kycVerificado: data['kyc_verificado'] ?? false,
      serviciosActivos: data['servicios_activos'] ?? true,
    );
  }

  // Convertir de Dart a Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
      'fechaRegistro': fechaRegistro,
      'profesion': profesion,
      'tarifa': tarifa,
      'kyc_verificado': kycVerificado,
      'servicios_activos': serviciosActivos,
    };
  }
}