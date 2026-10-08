// Archivo: lib/screens/ganancias_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Ideal para formatear números como moneda (opcional, pero recomendado)

class GananciasScreen extends StatelessWidget {
  const GananciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colorNegro = Color(0xFF000000);
    const colorAzul = Color(0xFF2F65F6);

    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return const Center(child: Text('Error: Sesión no encontrada'));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          // Escuchamos el documento del doctor en tiempo real
          stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Cargando billetera...'));
            }

            var datos = snapshot.data!.data() as Map<String, dynamic>;
            // Extraemos el saldo numérico (si no hay, asumimos 0)
            num saldoAcumulado = datos['saldo'] ?? 0;

            // Formateamos el número para que se vea como dinero (Ej: 30800 -> $30.800)
            final formatoMoneda = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);
            String saldoTexto = formatoMoneda.format(saldoAcumulado);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text('Mis Ganancias', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorNegro, letterSpacing: -0.5)),
                  const SizedBox(height: 30),

                  // --- TARJETA DE BILLETERA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: colorNegro,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: colorNegro.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo Disponible', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(saldoTexto, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            // Aquí iría la lógica para transferir al banco
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Función de retiro bancario en desarrollo')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorNegro,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text('Retirar Dinero', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- HISTORIAL RECIENTE (Visual) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Historial reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorNegro)),
                      TextButton(onPressed: () {}, child: const Text('Ver todo', style: TextStyle(color: colorAzul))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Elemento de lista simulado
                  _crearTransaccionVisual('Pago por consulta', saldoTexto, 'Hoy', true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget auxiliar para que el historial se vea bonito
  Widget _crearTransaccionVisual(String titulo, String monto, String fecha, bool esIngreso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: esIngreso ? Colors.green[50] : Colors.red[50], shape: BoxShape.circle),
            child: Icon(esIngreso ? Icons.arrow_downward : Icons.arrow_upward, color: esIngreso ? Colors.green : Colors.red, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(fecha, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(monto, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: esIngreso ? Colors.green : Colors.black)),
        ],
      ),
    );
  }
}