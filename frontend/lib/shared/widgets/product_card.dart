import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../features/catalog/domain/product.dart';
import 'app_image.dart';
import 'price_tag.dart';
import 'rating_stars.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onWishlist;
  final bool wishlisted;
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onWishlist,
    this.wishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: AppImage(product.thumbnailUrl),
              ),
            ),
            if (onWishlist != null)
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: onWishlist,
                  child: CircleAvatar(
                    radius: 16, backgroundColor: Colors.white,
                    child: Icon(wishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 18, color: wishlisted ? AppColors.error : AppColors.textSecondary),
                  ),
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((product.brandName ?? '').toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              RatingStars(rating: product.ratingAvg, size: 13),
              const SizedBox(height: 6),
              PriceTag(price: product.price, salePrice: product.salePrice, size: 16),
            ]),
          ),
        ]),
      ),
    );
  }
}
