import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financial_plan_model.dart';

/// Servicio para manejar operaciones CRUD de planes financieros
class FinancialPlansService {
  static const String _collection = 'financial_plans';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener todos los planes financieros de un usuario
  Future<List<FinancialPlanModel>> getUserFinancialPlans(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => FinancialPlanModel.fromMap({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      print('Error al obtener planes financieros: $e');
      return [];
    }
  }

  /// Obtener plan financiero específico por mes y año
  Future<FinancialPlanModel?> getPlanByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('year', isEqualTo: year)
          .where('month', isEqualTo: month)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return FinancialPlanModel.fromMap({...doc.data(), 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error al obtener plan del mes: $e');
      return null;
    }
  }

  /// Crear un nuevo plan financiero
  Future<String?> createFinancialPlan(FinancialPlanModel plan) async {
    try {
      // Verificar que no exista un plan para el mismo mes/año
      final existingPlan = await getPlanByMonth(
        userId: plan.userId,
        year: plan.year,
        month: plan.month,
      );

      if (existingPlan != null) {
        throw Exception(
          'Ya existe un plan para ${plan.monthName} ${plan.year}',
        );
      }

      final docRef = await _firestore.collection(_collection).add(plan.toMap());

      // Actualizar con el ID generado
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      print('Error al crear plan financiero: $e');
      rethrow;
    }
  }

  /// Actualizar un plan financiero existente
  Future<bool> updateFinancialPlan(FinancialPlanModel plan) async {
    try {
      if (plan.id.isEmpty) {
        throw Exception('El plan debe tener un ID válido');
      }

      final updatedPlan = plan.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(plan.id)
          .update(updatedPlan.toMap());

      return true;
    } catch (e) {
      print('Error al actualizar plan financiero: $e');
      return false;
    }
  }

  /// Actualizar gasto en una categoría específica
  Future<bool> updateCategorySpent({
    required String planId,
    required String categoryId,
    required double newSpentAmount,
  }) async {
    try {
      final planDoc = await _firestore
          .collection(_collection)
          .doc(planId)
          .get();

      if (!planDoc.exists) {
        throw Exception('Plan no encontrado');
      }

      final plan = FinancialPlanModel.fromMap({
        ...planDoc.data()!,
        'id': planDoc.id,
      });

      // Actualizar la categoría específica
      final updatedCategoryBudgets = plan.categoryBudgets.map((cb) {
        if (cb.categoryId == categoryId) {
          return cb.copyWith(spentAmount: newSpentAmount);
        }
        return cb;
      }).toList();

      final updatedPlan = plan.copyWith(
        categoryBudgets: updatedCategoryBudgets,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(planId)
          .update(updatedPlan.toMap());

      return true;
    } catch (e) {
      print('Error al actualizar gasto de categoría: $e');
      return false;
    }
  }

  /// Eliminar (desactivar) un plan financiero
  Future<bool> deleteFinancialPlan(String planId) async {
    try {
      await _firestore.collection(_collection).doc(planId).update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error al eliminar plan financiero: $e');
      return false;
    }
  }

  /// Obtener planes por año
  Future<List<FinancialPlanModel>> getPlansByYear({
    required String userId,
    required int year,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('year', isEqualTo: year)
          .where('isActive', isEqualTo: true)
          .orderBy('month', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => FinancialPlanModel.fromMap({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } catch (e) {
      print('Error al obtener planes del año: $e');
      return [];
    }
  }

  /// Duplicar plan del mes anterior
  Future<String?> duplicatePreviousMonth({
    required String userId,
    required int targetYear,
    required int targetMonth,
  }) async {
    try {
      // Calcular mes/año anterior
      int prevMonth = targetMonth - 1;
      int prevYear = targetYear;

      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear = targetYear - 1;
      }

      // Obtener el plan del mes anterior
      final previousPlan = await getPlanByMonth(
        userId: userId,
        year: prevYear,
        month: prevMonth,
      );

      if (previousPlan == null) {
        throw Exception('No existe plan del mes anterior para duplicar');
      }

      // Crear nuevo plan basado en el anterior (reseteando gastos)
      final newCategoryBudgets = previousPlan.categoryBudgets
          .map((cb) => cb.copyWith(spentAmount: 0.0))
          .toList();

      final newPlan = previousPlan.copyWith(
        id: '',
        year: targetYear,
        month: targetMonth,
        categoryBudgets: newCategoryBudgets,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await createFinancialPlan(newPlan);
    } catch (e) {
      print('Error al duplicar plan del mes anterior: $e');
      rethrow;
    }
  }

  /// Calcular estadísticas del plan
  Future<Map<String, dynamic>> getPlanStatistics(String planId) async {
    try {
      final planDoc = await _firestore
          .collection(_collection)
          .doc(planId)
          .get();

      if (!planDoc.exists) {
        throw Exception('Plan no encontrado');
      }

      final plan = FinancialPlanModel.fromMap({
        ...planDoc.data()!,
        'id': planDoc.id,
      });

      return {
        'totalBudget': plan.totalBudget,
        'totalSpent': plan.totalSpent,
        'remainingBudget': plan.remainingBudget,
        'usagePercentage': plan.totalUsagePercentage,
        'isOverBudget': plan.isOverBudget,
        'categoriesCount': plan.categoryBudgets.length,
        'overBudgetCategories': plan.categoryBudgets
            .where((cb) => cb.isOverBudget)
            .length,
      };
    } catch (e) {
      print('Error al calcular estadísticas: $e');
      return {};
    }
  }

  /// Obtener un plan financiero por ID
  Future<FinancialPlanModel?> getPlanById(String planId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(planId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return FinancialPlanModel.fromMap({
        ...doc.data()!,
        'id': doc.id,
      });
    } catch (e) {
      print('Error al obtener plan por ID: $e');
      return null;
    }
  }
}
