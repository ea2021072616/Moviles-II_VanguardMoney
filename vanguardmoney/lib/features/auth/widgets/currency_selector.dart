import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../constants/auth_constants.dart';

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onChanged,
  });

  final String selectedCurrency;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: Colors.black26),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: DropdownButtonFormField<String>(
        value: selectedCurrency,
        decoration: InputDecoration(
          labelText: 'Moneda',
          prefixIcon: Icon(
            Icons.monetization_on_outlined,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.spaceM,
            vertical: AppSizes.spaceS,
          ),
        ),
        items: AuthConstants.currencies.map((currency) {
          return DropdownMenuItem<String>(
            value: currency['code'],
            child: Text(
              currency['name']!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor selecciona una moneda';
          }
          return null;
        },
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
      ),
    );
  }
}
