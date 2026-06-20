import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn(IconData icon, VoidCallback? onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18,
                color: onTap == null ? AppColors.border : AppColors.primary),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        btn(Icons.remove, quantity > 1 ? () => onChanged(quantity - 1) : null),
        SizedBox(width: 28, child: Text('$quantity', textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        btn(Icons.add, quantity < max ? () => onChanged(quantity + 1) : null),
      ]),
    );
  }
}
