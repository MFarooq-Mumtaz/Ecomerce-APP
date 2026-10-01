import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    this.imageUrl,
    this.localImagePath,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final String? localImagePath;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final localPath = localImagePath?.trim();
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              const ProductImageFallback(),
        );
      }
    }

    final path = imageUrl?.trim();
    if (path == null || path.isEmpty) {
      return const ProductImageFallback();
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const ProductImageFallback(icon: Icons.broken_image_outlined),
      );
    }

    return Image.network(
      path,
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
