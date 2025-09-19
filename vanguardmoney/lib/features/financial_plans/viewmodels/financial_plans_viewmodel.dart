import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/financial_plan_model.dart';

/// Estados para el ViewModel de planes financieros
sealed class FinancialPlansState {
  const FinancialPlansState();
}

class FinancialPlansInitial extends FinancialPlansState {
  const FinancialPlansInitial();
}

class FinancialPlansLoading extends FinancialPlansState {
  const FinancialPlansLoading();
}

class FinancialPlansLoaded extends FinancialPlansState {
  final List<FinancialPlan> plans;
  const FinancialPlansLoaded(this.plans);
}

class FinancialPlansError extends FinancialPlansState {
  final String message;
  const FinancialPlansError(this.message);
}

/// ViewModel para manejar los planes financieros
class FinancialPlansViewModel extends StateNotifier<FinancialPlansState> {
  FinancialPlansViewModel() : super(const FinancialPlansInitial());

  /// Cargar planes financieros del usuario
  Future<void> loadFinancialPlans(String userId) async {
    state = const FinancialPlansLoading();

    try {
      // TODO: Implementar servicio para cargar planes desde Firestore
      await Future.delayed(const Duration(seconds: 1)); // Simulación

      // Datos de ejemplo
      final plans = [
        FinancialPlan(
          id: '1',
          userId: userId,
          name: 'Fondo de Emergencia',
          description: 'Ahorrar 6 meses de gastos',
          targetAmount: 10000.0,
          currentAmount: 6500.0,
          targetDate: DateTime.now().add(const Duration(days: 180)),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
          status: FinancialPlanStatus.active,
          category: FinancialPlanCategory.emergency,
        ),
        FinancialPlan(
          id: '2',
          userId: userId,
          name: 'Vacaciones Europa',
          description: 'Viaje de 2 semanas por Europa',
          targetAmount: 5000.0,
          currentAmount: 2300.0,
          targetDate: DateTime.now().add(const Duration(days: 120)),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
          status: FinancialPlanStatus.active,
          category: FinancialPlanCategory.travel,
        ),
      ];

      state = FinancialPlansLoaded(plans);
    } catch (e) {
      state = FinancialPlansError('Error al cargar planes: $e');
    }
  }

  /// Crear un nuevo plan financiero
  Future<void> createPlan(FinancialPlan plan) async {
    // TODO: Implementar creación en Firestore
    await Future.delayed(const Duration(milliseconds: 500));

    if (state is FinancialPlansLoaded) {
      final currentPlans = (state as FinancialPlansLoaded).plans;
      final updatedPlans = [...currentPlans, plan];
      state = FinancialPlansLoaded(updatedPlans);
    }
  }

  /// Actualizar un plan existente
  Future<void> updatePlan(FinancialPlan updatedPlan) async {
    // TODO: Implementar actualización en Firestore
    await Future.delayed(const Duration(milliseconds: 500));

    if (state is FinancialPlansLoaded) {
      final currentPlans = (state as FinancialPlansLoaded).plans;
      final updatedPlans = currentPlans
          .map((plan) => plan.id == updatedPlan.id ? updatedPlan : plan)
          .toList();
      state = FinancialPlansLoaded(updatedPlans);
    }
  }

  /// Eliminar un plan
  Future<void> deletePlan(String planId) async {
    // TODO: Implementar eliminación en Firestore
    await Future.delayed(const Duration(milliseconds: 500));

    if (state is FinancialPlansLoaded) {
      final currentPlans = (state as FinancialPlansLoaded).plans;
      final updatedPlans = currentPlans
          .where((plan) => plan.id != planId)
          .toList();
      state = FinancialPlansLoaded(updatedPlans);
    }
  }

  /// Añadir dinero a un plan
  Future<void> addMoneyToPlan(String planId, double amount) async {
    if (state is FinancialPlansLoaded) {
      final currentPlans = (state as FinancialPlansLoaded).plans;
      final updatedPlans = currentPlans.map((plan) {
        if (plan.id == planId) {
          final newAmount = plan.currentAmount + amount;
          final status = newAmount >= plan.targetAmount
              ? FinancialPlanStatus.completed
              : plan.status;
          return plan.copyWith(
            currentAmount: newAmount,
            status: status,
            updatedAt: DateTime.now(),
          );
        }
        return plan;
      }).toList();

      state = FinancialPlansLoaded(updatedPlans);

      // TODO: Guardar en Firestore
    }
  }
}

/// Provider para el ViewModel de planes financieros
final financialPlansViewModelProvider =
    StateNotifierProvider<FinancialPlansViewModel, FinancialPlansState>(
      (ref) => FinancialPlansViewModel(),
    );
