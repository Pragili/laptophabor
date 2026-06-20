import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/config/dev_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/image_url.dart';

/// Maps a backend image ref to a bundled asset when running in mock mode,
/// e.g. '/uploads/laptop-3-b.png' -> 'assets/laptops/laptop-3-b.png'.
String? assetForRef(String? raw) {
  if (!kUseMockBackend || raw == null) return null;
  final m = RegExp(r'/uploads/(laptop-\d+(?:-[bc])?\.png)').firstMatch(raw);
  return m != null ? 'assets/laptops/${m.group(1)}' : null;
}

/// ImageProvider variant for places that need one (e.g. CircleAvatar).
ImageProvider? appImageProvider(String? raw) {
  final asset = assetForRef(raw);
  if (asset != null) return AssetImage(asset);
  final url = resolveImageUrl(raw);
  return url.isEmpty ? null : NetworkImage(url);
}

/// Drop-in image widget: assets in mock mode, cached network otherwise,
/// with a consistent placeholder/fallback.
class AppImage extends StatelessWidget {
  final String? raw;
  final BoxFit fit;
  const AppImage(this.raw, {super.key, this.fit = BoxFit.cover});

  Widget get _placeholder => Container(
        color: AppColors.surfaceAlt,
        child: const Icon(Icons.laptop, size: 40, color: AppColors.border),
      );

  @override
  Widget build(BuildContext context) {
    final asset = assetForRef(raw);
    if (asset != null) {
      return Image.asset(asset, fit: fit,
          errorBuilder: (_, __, ___) => _placeholder);
    }
    final url = resolveImageUrl(raw);
    if (url.isEmpty) return _placeholder;
    return CachedNetworkImage(
      imageUrl: url, fit: fit,
      placeholder: (_, __) => Container(color: AppColors.surfaceAlt),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.broken_image, color: AppColors.border),
    );
  }
}
