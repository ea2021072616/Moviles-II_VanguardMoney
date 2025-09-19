import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../reports/views/reports_page.dart';

// TAB CONTAINER: Solo llama al módulo de reportes
class ReportesTabPage extends ConsumerWidget {
  const ReportesTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Llamar directo al módulo - sin duplicar lógica
    return const ReportsPage();
  }
}
