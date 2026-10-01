import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalProductImageService {
  Future<String> saveProductImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw const FileSystemException('Selected image does not exist.');
    }

    final directory = await _productImagesDirectory();
    final extension = _safeExtension(sourcePath);
    final fileName =
        'product_${DateTime.now().microsecondsSinceEpoch}$extension';
    final targetPath = '${directory.path}${Platform.pathSeparator}$fileName';

    final copiedFile = await sourceFile.copy(targetPath);
    return copiedFile.path;
  }

  Future<void> deleteIfOwnedProductImage(String? path) async {
    if (path == null || path.trim().isEmpty || path.startsWith('assets/')) {
      return;
    }

    final directory = await _productImagesDirectory();
    final file = File(path);
    if (!_isInsideDirectory(file, directory)) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _productImagesDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}products'
      '${Platform.pathSeparator}images',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  bool _isInsideDirectory(File file, Directory directory) {
    final filePath = file.absolute.path;
    final directoryPath = directory.absolute.path;
    final directoryPrefix = directoryPath.endsWith(Platform.pathSeparator)
        ? directoryPath
        : '$directoryPath${Platform.pathSeparator}';
    return filePath == directoryPath || filePath.startsWith(directoryPrefix);
  }

  String _safeExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }

    final extension = path.substring(dotIndex).toLowerCase();
    const allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};
    return allowedExtensions.contains(extension) ? extension : '.jpg';
  }
}
