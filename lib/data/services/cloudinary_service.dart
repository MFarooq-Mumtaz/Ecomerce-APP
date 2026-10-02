import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/cloudinary_config.dart';

class CloudinaryUploadFailure implements Exception {
  const CloudinaryUploadFailure(this.message);

  final String message;
}

class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
  });

  final String secureUrl;
  final String publicId;
}

class CloudinaryService {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<CloudinaryUploadResult> uploadProductImage(String filePath) {
    return _uploadImage(
      filePath: filePath,
      folder: CloudinaryConfig.productFolder,
    );
  }

  Future<CloudinaryUploadResult> uploadProfileImage(String filePath) {
    return _uploadImage(
      filePath: filePath,
      folder: CloudinaryConfig.profileFolder,
    );
  }

  Future<CloudinaryUploadResult> _uploadImage({
    required String filePath,
    required String folder,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const CloudinaryUploadFailure('Selected image was not found.');
    }

    final request =
        http.MultipartRequest(
            'POST',
            Uri.https(
              'api.cloudinary.com',
              '/v1_1/${CloudinaryConfig.cloudName}/image/upload',
            ),
          )
          ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
          ..fields['folder'] = folder
          ..fields['tags'] = 'avero'
          ..files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CloudinaryUploadFailure(_errorMessage(response.body));
      }

      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const CloudinaryUploadFailure(
          'Cloudinary returned an invalid response.',
        );
      }

      final secureUrl = json['secure_url'] as String?;
      final publicId = json['public_id'] as String?;
      if (secureUrl == null || publicId == null) {
        throw const CloudinaryUploadFailure(
          'Cloudinary upload response is missing image data.',
        );
      }

      return CloudinaryUploadResult(secureUrl: secureUrl, publicId: publicId);
    } on TimeoutException {
      throw const CloudinaryUploadFailure(
        'Image upload timed out. Please try again.',
      );
    } on CloudinaryUploadFailure {
      rethrow;
    } catch (_) {
      throw const CloudinaryUploadFailure(
        'Image could not be uploaded. Please try again.',
      );
    }
  }

  String _errorMessage(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String?;
          if (message != null && message.trim().isNotEmpty) {
            return message;
          }
        }
      }
    } catch (_) {
      // Use generic message below when Cloudinary does not return JSON.
    }

    return 'Cloudinary upload failed. Please try again.';
  }
}
