import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../models/financial_analysis_model.dart';
import '../viewmodels/financial_analysis_viewmodel.dart';
import '../widgets/summary_cards.dart';
import '../widgets/category_insights_section.dart';
import '../widgets/patterns_section.dart';
import '../widgets/recommendations_section.dart';
import '../widgets/period_selector.dart';
import '../widgets/ai_explanation_card.dart';

/// Vista principal del análisis financiero
class FinancialAnalysisView extends ConsumerStatefulWidget {
  const FinancialAnalysisView({super.key});

  @override
  ConsumerState<FinancialAnalysisView> createState() =>
      _FinancialAnalysisViewState();
}

class _FinancialAnalysisViewState extends ConsumerState<FinancialAnalysisView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financialAnalysisViewModelProvider(_userId));
    final viewModel = ref.read(
      financialAnalysisViewModelProvider(_userId).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Financiero'),
        centerTitle: true,
        backgroundColor: AppColors.blueClassic,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón de historial
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistorySheet(context),
            tooltip: 'Ver historial',
          ),
        ],
      ),
      body: _userId.isEmpty
          ? _buildEmptyState('Inicia sesión para ver tu análisis financiero')
          : RefreshIndicator(
              onRefresh: () => viewModel.runAnalysis(),
              child: CustomScrollView(
                slivers: [
                  // Selector de período
                  SliverToBoxAdapter(
                    child: PeriodSelector(
                      userId: _userId,
                      onPeriodChanged: () {
                        // Auto-ejecutar análisis al cambiar período
                        Future.delayed(const Duration(milliseconds: 300), () {
                          viewModel.runAnalysis();
                        });
                      },
                    ),
                  ),

                  // Contenido principal
                  if (state.isLoading)
                    SliverFillRemaining(child: _buildLoadingState())
                  else if (state.errorMessage != null)
                    SliverFillRemaining(
                      child: _buildErrorState(state.errorMessage!, viewModel),
                    )
                  else if (state.currentAnalysis == null)
                    SliverFillRemaining(
                      child: _buildEmptyAnalysisState(viewModel),
                    )
                  else
                    _buildAnalysisContent(state.currentAnalysis!),
                ],
              ),
            ),
      floatingActionButton: state.currentAnalysis != null && !state.isLoading
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
              ), // Separación del borde
              child: FloatingActionButton.extended(
                onPressed: state.isSaving
                    ? null
                    : () => _saveAnalysis(viewModel, state),
                icon: state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.bookmark_add_outlined, size: 22),
                label: Text(
                  state.isSaving ? 'Guardando...' : 'Guardar Análisis',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                backgroundColor: state.isSaving
                    ? AppColors.greyDark
                    : AppColors.blueClassic,
                foregroundColor: Colors.white,
                elevation: 6,
                highlightElevation: 10,
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analizando tus finanzas con IA...',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.greyDark),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Esto puede tomar unos segundos',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, FinancialAnalysisViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.redCoral),
            const SizedBox(height: 24),
            Text(
              'Error al ejecutar análisis',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.runAnalysis(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAnalysisState(FinancialAnalysisViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 80,
                color: AppColors.blueClassic.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Análisis Financiero Inteligente',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Obtén insights personalizados sobre tus finanzas usando inteligencia artificial',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.greyDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildFeatureList(),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => viewModel.runAnalysis(),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Ejecutar Análisis con IA'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: AppColors.greyDark),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      '📊 Resumen completo de ingresos y gastos',
      '📈 Análisis detallado por categorías',
      '🔍 Detección de patrones de gasto',
      '💡 Recomendaciones personalizadas con IA',
      '💰 Identificación de oportunidades de ahorro',
    ];

    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAnalysisContent(FinancialAnalysisModel analysis) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Resumen financiero
        SummaryCards(summary: analysis.summary),

        // Explicación de IA
        if (analysis.aiGeneratedText != null)
          AIExplanationCard(text: analysis.aiGeneratedText!),

        // Tabs de contenido
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.blueClassic,
            unselectedLabelColor: AppColors.greyDark,
            indicatorColor: AppColors.blueClassic,
            tabs: const [
              Tab(text: 'Categorías'),
              Tab(text: 'Patrones'),
              Tab(text: 'Recomendaciones'),
              Tab(text: 'Detalles'),
            ],
          ),
        ),

        // Contenido de tabs
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Categorías
              CategoryInsightsSection(insights: analysis.categoryInsights),

              // Tab 2: Patrones
              PatternsSection(patterns: analysis.patterns),

              // Tab 3: Recomendaciones
              RecommendationsSection(recommendations: analysis.recommendations),

              // Tab 4: Detalles
              _buildDetailsTab(analysis),
            ],
          ),
        ),

        const SizedBox(height: 80), // Espacio para FAB
      ]),
    );
  }

  Widget _buildDetailsTab(FinancialAnalysisModel analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard('Información del Análisis', [
            _buildDetailRow('Período', analysis.period.label),
            _buildDetailRow(
              'Fecha de análisis',
              _formatDateTime(analysis.createdAt),
            ),
            _buildDetailRow(
              'Total de transacciones',
              '${analysis.summary.transactionCount}',
            ),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Estadísticas', [
            _buildDetailRow(
              'Gasto promedio',
              '\$${analysis.summary.averageExpense.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Gasto más grande',
              '\$${analysis.summary.largestExpense.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Categoría del gasto más grande',
              analysis.summary.largestExpenseCategory,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.greyDark),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _saveAnalysis(
    FinancialAnalysisViewModel viewModel,
    FinancialAnalysisState state,
  ) async {
    await viewModel.saveCurrentAnalysis();

    if (mounted && state.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Análisis guardado exitosamente'),
          backgroundColor: AppColors.greenJade,
        ),
      );
    }
  }

  void _showHistorySheet(BuildContext context) {
    final history = ref.read(analysisHistoryProvider(_userId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blueClassic,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Historial de Análisis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),

            // Lista de análisis
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.greyDark,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay análisis guardados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: history.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final analysis = history[index];
                        return _buildHistoryItem(ctx, analysis);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext ctx, FinancialAnalysisModel analysis) {
    final viewModel = ref.read(
      financialAnalysisViewModelProvider(_userId).notifier,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.blueClassic.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.analytics, color: AppColors.blueClassic),
        ),
        title: Text(
          analysis.period.label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_formatDateTime(analysis.createdAt)),
            const SizedBox(height: 4),
            Text(
              'Balance: \$${analysis.summary.balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: analysis.summary.balance >= 0
                    ? AppColors.greenJade
                    : AppColors.redCoral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(ctx);
          viewModel.loadAnalysis(analysis);
        },
      ),
    );
  }
}
