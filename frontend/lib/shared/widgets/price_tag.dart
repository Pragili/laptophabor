import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final double? salePrice;
  final double size;
  const PriceTag({super.key, required this.price, this.salePrice, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final hasSale = salePrice != null && salePrice! < price;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(money(hasSale ? salePrice : price),
            style: TextStyle(
                fontSize: size, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (hasSale) ...[
          const SizedBox(width: 6),
          Text(money(price),
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 13)),
        ],
      ],
    );
  }
}
