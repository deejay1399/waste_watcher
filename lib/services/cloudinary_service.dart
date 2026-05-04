import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const _cloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
  );

  static Future<String?> uploadImage(File imageFile) async {
    _ensureConfigured();

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      if (response.statusCode == 200) {
        return json['secure_url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static void _ensureConfigured() {
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw StateError(
        'Missing Cloudinary config. Pass CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET with --dart-define or '
        '--dart-define-from-file=config/cloudinary.local.json.',
      );
    }
  }
}
