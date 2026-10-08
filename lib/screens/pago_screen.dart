// Archivo: lib/screens/pago_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'estado_servicio_screen.dart';

class PagoScreen extends StatefulWidget {
  final String servicio;
  final String precio;

  const PagoScreen({
    super.key,
    required this.servicio,
    required this.precio,
  });

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  bool _isLoading = false;

  Future<void> _procesarPagoYPedirEspecialista() async {
    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // --- NUEVA VALIDACIÓN: EVITAR SOLICITUDES DUPLICADAS ---
      var solicitudesActivas = await FirebaseFirestore.instance
          .collection('solicitudes')
          .where('pacienteId', isEqualTo: uid)
          .where('estado', whereIn: ['buscando', 'aceptado'])
          .get();

      if (solicitudesActivas.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes un servicio en curso. Finalízalo antes de pedir otro.'), backgroundColor: Colors.orange),
        );
        setState(() => _isLoading = false);
        return;
      }
      // --------------------------------------------------------

      DocumentSnapshot pacienteDoc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
      String nombrePaciente = pacienteDoc['nombre'] ?? 'Paciente';

      await FirebaseFirestore.instance.collection('solicitudes').add({
        'pacienteId': uid,
        'pacienteNombre': nombrePaciente,
        'servicio': widget.servicio,
        'precio': widget.precio,
        'direccion': 'Av. Carlos Condell 1687',
        'latitudDestino': -32.8755,
        'longitudDestino': -71.2415,
        'estado': 'buscando', 
        'fecha': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EstadoServicioScreen(tituloServicio: widget.servicio)),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al procesar la solicitud'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Confirmar Pago', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Servicio solicitado', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 5),
                        Text(widget.servicio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Text(widget.precio, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: colorAzul)),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              const Text('Método de pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorNegro)),
              const SizedBox(height: 20),

              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '0000 0000 0000 0000',
                  labelText: 'Número de Tarjeta',
                  prefixIcon: const Icon(Icons.credit_card, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                        _ExpirationDateFormatter(),
                      ],
                      decoration: InputDecoration(hintText: 'MM/AA', labelText: 'Vencimiento', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(hintText: '123', labelText: 'CVV', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _procesarPagoYPedirEspecialista,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorNegro,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('Pagar ${widget.precio}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}