import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/financial_plan_model.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryBudgetCard extends StatefulWidget {
  final CategoryBudget categoryBudget;
  final Function(double)? onUpdateSpent;

  const CategoryBudgetCard({
    super.key,
    required this.categoryBudget,
    this.onUpdateSpent,
  });

  @override
  State<CategoryBudgetCard> createState() => _CategoryBudgetCardState();
}

class _CategoryBudgetCardState extends State<CategoryBudgetCard> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.categoryBudget.spentAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.categoryBudget.isOverBudget
              ? AppColors.redCoral.withOpacity(0.3)
              : AppColors.greyLight,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y botón editar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.categoryBudget.categoryName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onUpdateSpent != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (!_isEditing) {
                          _saveChanges();
                        }
                      });
                    },
                    icon: Icon(
                      _isEditing ? Icons.check : Icons.edit,
                      size: 20,
                      color: _isEditing
                          ? AppColors.greenJade
                          : AppColors.greyMedium,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Información de presupuesto y gasto
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gastado',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (_isEditing)
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: TextField(
                            controller: _controller,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            decoration: InputDecoration(
                              prefixText: 'S/ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.greyMedium,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.blueClassic,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      else
                        Text(
                          'S/ ${widget.categoryBudget.spentAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.categoryBudget.isOverBudget
                                ? AppColors.redCoral
                                : AppColors.blackGrey,
                          ),
                        ),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Presupuesto',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.greyMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'S/ ${widget.categoryBudget.budgetAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _getProgressColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.categoryBudget.usagePercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getProgressColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.greyMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.categoryBudget.isOverBudget
                          ? 'Sobre presupuesto: S/ ${(widget.categoryBudget.spentAmount - widget.categoryBudget.budgetAmount).toStringAsFixed(2)}'
                          : 'Restante: S/ ${widget.categoryBudget.remainingAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.categoryBudget.isOverBudget
                            ? AppColors.redCoral
                            : AppColors.greenJade,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: (widget.categoryBudget.usagePercentage / 100).clamp(
                    0.0,
                    1.0,
                  ),
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(),
                  ),
                  minHeight: 6,
                ),
              ],
            ),

            // Mensaje de advertencia si está sobre presupuesto
            if (widget.categoryBudget.isOverBudget) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.redCoral.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      size: 16,
                      color: AppColors.redCoral,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '¡Has superado el presupuesto de esta categoría!',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.redCoral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    // Generar color basado en el nombre de la categoría para consistencia
    final hash = widget.categoryBudget.categoryName.hashCode;
    final colors = [
      AppColors.blueClassic,
      AppColors.greenJade,
      AppColors.pinkPastel,
      AppColors.yellowPastel,
      AppColors.redCoral,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getProgressColor() {
    if (widget.categoryBudget.isOverBudget) {
      return AppColors.redCoral;
    } else if (widget.categoryBudget.usagePercentage > 80) {
      return AppColors.yellowPastel;
    } else {
      return AppColors.greenJade;
    }
  }

  void _saveChanges() {
    final newAmount =
        double.tryParse(_controller.text) ?? widget.categoryBudget.spentAmount;
    if (newAmount != widget.categoryBudget.spentAmount &&
        widget.onUpdateSpent != null) {
      widget.onUpdateSpent!(newAmount);
    }
  }
}
