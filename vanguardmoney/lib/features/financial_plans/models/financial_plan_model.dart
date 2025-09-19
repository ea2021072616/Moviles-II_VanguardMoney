/// Modelo para representar un plan financiero
class FinancialPlan {
  final String id;
  final String userId;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FinancialPlanStatus status;
  final FinancialPlanCategory category;

  const FinancialPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.category,
  });

  /// Factory constructor desde Map (Firestore)
  factory FinancialPlan.fromMap(Map<String, dynamic> map) {
    return FinancialPlan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0).toDouble(),
      currentAmount: (map['currentAmount'] ?? 0).toDouble(),
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      status: FinancialPlanStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => FinancialPlanStatus.active,
      ),
      category: FinancialPlanCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => FinancialPlanCategory.savings,
      ),
    );
  }

  /// Convierte a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'status': status.name,
      'category': category.name,
    };
  }

  /// Copia con nuevos valores
  FinancialPlan copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    FinancialPlanStatus? status,
    FinancialPlanCategory? category,
  }) {
    return FinancialPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  /// Progreso del plan (0.0 - 1.0)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  /// Porcentaje de progreso
  double get progressPercentage => progress * 100;

  /// Días restantes hasta la fecha objetivo
  int get daysRemaining {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  /// Monto restante para completar el plan
  double get remainingAmount =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FinancialPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FinancialPlan(id: $id, name: $name, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}

/// Estados posibles de un plan financiero
enum FinancialPlanStatus {
  active,
  completed,
  paused,
  cancelled;

  String get displayName {
    switch (this) {
      case FinancialPlanStatus.active:
        return 'Activo';
      case FinancialPlanStatus.completed:
        return 'Completado';
      case FinancialPlanStatus.paused:
        return 'Pausado';
      case FinancialPlanStatus.cancelled:
        return 'Cancelado';
    }
  }
}

/// Categorías de planes financieros
enum FinancialPlanCategory {
  savings,
  investment,
  emergency,
  retirement,
  education,
  travel,
  other;

  String get displayName {
    switch (this) {
      case FinancialPlanCategory.savings:
        return 'Ahorros';
      case FinancialPlanCategory.investment:
        return 'Inversión';
      case FinancialPlanCategory.emergency:
        return 'Emergencia';
      case FinancialPlanCategory.retirement:
        return 'Jubilación';
      case FinancialPlanCategory.education:
        return 'Educación';
      case FinancialPlanCategory.travel:
        return 'Viajes';
      case FinancialPlanCategory.other:
        return 'Otros';
    }
  }
}
