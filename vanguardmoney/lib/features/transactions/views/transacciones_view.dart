import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ingreso/register_ingreso_view.dart';
import 'egreso/register_bill_view.dart';
import 'registrar_con_ia_screen.dart';
import '../viewmodels/registrar_IA_viewmodel.dart';

class TransaccionesView extends StatelessWidget {
  final String idUsuario;
  const TransaccionesView({Key? key, required this.idUsuario})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: Colors.indigo[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¿Qué deseas registrar?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige una opción para continuar',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Opciones de transacciones
              Expanded(
                child: Column(
                  children: [
                    // Registrar Ingreso
                    _buildTransactionCard(
                      context: context,
                      title: 'Registrar Ingreso',
                      subtitle: 'Agregar dinero recibido',
                      icon: Icons.trending_up,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterIngresoView(idUsuario: idUsuario),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Registrar Egreso
                    _buildTransactionCard(
                      context: context,
                      title: 'Registrar Egreso',
                      subtitle: 'Agregar gasto realizado',
                      icon: Icons.trending_down,
                      color: Colors.deepOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RegisterBillView(idUsuario: idUsuario),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Registrar con IA
                    _buildTransactionCard(
                      context: context,
                      title: 'Registrar con IA',
                      subtitle: 'Describe tu transacción con lenguaje natural',
                      icon: Icons.auto_awesome,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => RegistrarMedianteIAViewModel(),
                              child: RegistrarConIAScreen(idUsuario: idUsuario),
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    // Tip informativo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tip: Puedes personalizar las categorías desde el botón ⚙️ en cada formulario',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),

                const SizedBox(width: 16),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
