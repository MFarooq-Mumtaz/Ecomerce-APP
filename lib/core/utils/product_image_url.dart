import '../../data/models/product_model.dart';
import '../constants/cloudinary_asset_urls.dart';

String? productImageUrl(ProductModel product) {
  final explicitUrl = product.imageUrl?.trim();
  if (explicitUrl != null && explicitUrl.isNotEmpty) {
    return cloudinaryAssetUrls[explicitUrl] ?? explicitUrl;
  }

  final key = _categoryKey(product.categoryName ?? product.categoryId);
  final presets = categoryProductImagePresets[key];
  if (presets == null || presets.isEmpty) {
    return null;
  }

  return presets[_stableIndex(product.id, presets.length)];
}

String? cloudinaryUrlForAsset(String? path) {
  final value = path?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  return cloudinaryAssetUrls[value] ?? value;
}

String _categoryKey(String? value) => value?.trim().toLowerCase() ?? '';

int _stableIndex(String value, int length) {
  if (length <= 1) {
    return 0;
  }

  final seed = value.codeUnits.fold<int>(0, (total, code) => total + code);
  return seed.abs() % length;
}
