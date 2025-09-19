import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../analysis/views/ai_analysis_page.dart';

// TAB CONTAINER: Solo llama al módulo de análisis IA
class AnalysisTabPage extends ConsumerWidget {
  const AnalysisTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Llamar directo al módulo - sin duplicar lógica
    return const AiAnalysisPage();
  }
}
