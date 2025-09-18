import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistroTabPage extends ConsumerStatefulWidget {
  const RegistroTabPage({super.key});

  @override
  ConsumerState<RegistroTabPage> createState() => _RegistroTabPageState();
}

class _RegistroTabPageState extends ConsumerState<RegistroTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Alimentación';
  DateTime _selectedDate = DateTime.now();

  final List<String> _incomeCategories = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Bonificaciones',
    'Ventas',
    'Otros ingresos',
  ];

  final List<String> _expenseCategories = [
    'Alimentación',
    'Transporte',
    'Servicios',
    'Entretenimiento',
    'Salud',
    'Educación',
    'Compras',
    'Otros gastos',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        // Cambiar categoría por defecto según la pestaña
        setState(() {
          _selectedCategory = _tabController.index == 0
              ? _incomeCategories.first
              : _expenseCategories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tabs para Ingresos/Egresos
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.primary,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(icon: Icon(Icons.add_circle_outline), text: 'Ingresos'),
                Tab(icon: Icon(Icons.remove_circle_outline), text: 'Egresos'),
              ],
            ),
          ),

          // Contenido del formulario
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionForm(true), // Ingresos
                _buildTransactionForm(false), // Egresos
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(bool isIncome) {
    final categories = isIncome ? _incomeCategories : _expenseCategories;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 48, color: color),
                  const SizedBox(height: 8),
                  Text(
                    isIncome ? 'Registrar Ingreso' : 'Registrar Egreso',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Campo de monto
            Text(
              'Monto *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'S/ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Por favor ingresa un número válido';
                }
                if (double.parse(value) <= 0) {
                  return 'El monto debe ser mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Campo de categoría
            Text(
              'Categoría *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: categories.contains(_selectedCategory)
                  ? _selectedCategory
                  : categories.first,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Campo de descripción
            Text(
              'Descripción',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe brevemente esta transacción (opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 20),

            // Campo de fecha
            Text(
              'Fecha *',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _saveTransaction(isIncome),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: Text(
                  isIncome ? 'Guardar Ingreso' : 'Guardar Egreso',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction(bool isIncome) {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar guardado en base de datos
      final amount = double.parse(_amountController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isIncome
                ? 'Ingreso de S/ ${amount.toStringAsFixed(2)} guardado correctamente'
                : 'Egreso de S/ ${amount.toStringAsFixed(2)} guardado correctamente',
          ),
          backgroundColor: isIncome ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Limpiar formulario
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedCategory = isIncome
            ? _incomeCategories.first
            : _expenseCategories.first;
      });
    }
  }
}
