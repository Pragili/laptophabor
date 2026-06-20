import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final int? count;
  const RatingStars({super.key, required this.rating, this.size = 16, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < rating.round();
          return Icon(filled ? Icons.star : Icons.star_border,
              size: size, color: AppColors.star);
        }),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text('($count)', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Interactive variant for the review form.
class RatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const RatingInput({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => onChanged(i + 1),
          icon: Icon(i < value ? Icons.star : Icons.star_border,
              color: AppColors.star, size: 32),
        );
      }),
    );
  }
}
