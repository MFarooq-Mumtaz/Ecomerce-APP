import 'package:flutter/material.dart';

import '../utils/product_image_url.dart';
import '../theme/app_palette.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.imageUrl, this.fit = BoxFit.cover});

  final String? imageUrl;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = imageUrl?.trim();
    if (path == null || path.isEmpty) {
      return const ProductImageFallback();
    }

    final resolvedPath = cloudinaryUrlForAsset(path);
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return const ProductImageFallback();
    }

    if (resolvedPath.startsWith('assets/')) {
      return const ProductImageFallback(icon: Icons.broken_image_outlined);
    }

    return Image.network(
      resolvedPath,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return ColoredBox(
          color: context.colors.placeholder,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          const ProductImageFallback(icon: Icons.broken_image_outlined),
    );
  }
}

class ProductImageFallback extends StatelessWidget {
  const ProductImageFallback({super.key, this.icon = Icons.image_outlined});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.placeholder,
      child: Center(child: Icon(icon, color: context.colors.textMuted)),
    );
  }
}
