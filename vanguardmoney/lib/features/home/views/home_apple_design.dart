import 'package:flutter/material.dart';
import 'dart:math';

class AppleHomeDesign extends StatefulWidget {
  const AppleHomeDesign({super.key});

  @override
  State<AppleHomeDesign> createState() => _AppleHomeDesignState();
}

class _AppleHomeDesignState extends State<AppleHomeDesign> {
  // Datos de ejemplo - en producción vendrían del ViewModel
  final double currentBalance = 15420.50;
  final List<Map<String, dynamic>> recentTransactions = [
    {'type': 'income', 'amount': 2500.00, 'description': 'Salario mensual', 'date': 'Hoy'},
    {'type': 'expense', 'amount': -150.00, 'description': 'Café Starbucks', 'date': 'Ayer'},
    {'type': 'expense', 'amount': -89.99, 'description': 'Suscripción Netflix', 'date': 'Hace 2 días'},
    {'type': 'income', 'amount': 500.00, 'description': 'Freelance', 'date': 'Hace 3 días'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Fondo gris perla suave
      body: SafeArea(
        child: Column(
          children: [
            // Saldo principal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Actual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${currentBalance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1F),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ],
              ),
            ),

            // Gráfico de gastos vs ingresos
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Gastos vs Ingresos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    child: CustomPaint(
                      painter: _DonutPainter(),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: const Color(0xFF34C759), label: 'Ingresos'),
                      const SizedBox(width: 24),
                      _LegendDot(color: const Color(0xFFFF3B30), label: 'Gastos'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transacciones recientes
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transacciones Recientes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D1D1F),
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          return _TransactionRow(
                            type: transaction['type'],
                            amount: transaction['amount'],
                            description: transaction['description'],
                            date: transaction['date'],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // Espacio para la barra inferior
          ],
        ),
      ),

      // Botón flotante
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF007AFF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navegar a registrar nuevo movimiento
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barra inferior
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomNavIcon(
              icon: Icons.home,
              label: 'Inicio',
              isSelected: true,
              onTap: () {},
            ),
            _BottomNavIcon(
              icon: Icons.bar_chart,
              label: 'Estadísticas',
              isSelected: false,
              onTap: () {},
            ),
            const SizedBox(width: 56), // Espacio para el FAB
            _BottomNavIcon(
              icon: Icons.person,
              label: 'Perfil',
              isSelected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Círculo de fondo
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF2F2F7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Arco de ingresos (verde)
    final incomePaint = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * 0.7, // 70% ingresos
      false,
      incomePaint,
    );

    // Arco de gastos (rojo)
    final expensePaint = Paint()
      ..color = const Color(0xFFFF3B30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.4,
      2 * pi * 0.3, // 30% gastos
      false,
      expensePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final String type;
  final double amount;
  final String description;
  final String date;

  const _TransactionRow({
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
            color: isIncome ? const Color(0xFFE8F5E8) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D1D1F),
                  fontFamily: 'SF Pro Text',
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
        Text(
          '${isIncome ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isIncome ? const Color(0xFF34C759) : const Color(0xFFFF3B30),
            fontFamily: 'SF Pro Text',
          ),
        ),
      ],
    );
  }
}

class _BottomNavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF007AFF) : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF007AFF) : Colors.grey[400],
              fontFamily: 'SF Pro Text',
            ),
          ),
        ],
      ),
    );
  }
}