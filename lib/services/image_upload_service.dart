import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

abstract class ImageUploader {
  /// Dosyayı yükler, başarılıysa public görüntü URL'si döner.
  Future<String> uploadFile(XFile file);
}

/// --------------------
/// Imgur Anonymous Upload
/// --------------------
/// 1) https://api.imgur.com/oauth2/addclient → "Anonymous usage without a callback URL" seç.
/// 2) Client-ID'ni aşağıya gir.
class ImgurUploader implements ImageUploader {
  ImgurUploader(this.clientId);
  final String clientId;

  @override
  Future<String> uploadFile(XFile file) async {
    final bytes = await File(file.path).readAsBytes();
    final b64 = base64Encode(bytes);
    final uri = Uri.parse('https://api.imgur.com/3/image');

    final res = await http.post(
      uri,
      headers: {'Authorization': 'Client-ID $clientId'},
      body: {'image': b64, 'type': 'base64'},
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      final link = data?['link'] as String?;
      if (link != null && link.isNotEmpty) return link;
      throw Exception('Imgur: link alınamadı');
    } else {
      throw Exception('Imgur upload hatası: ${res.statusCode} ${res.body}');
    }
  }
}

/// --------------------
/// ImgBB Upload (alternatif)
/// --------------------
/// 1) https://api.imgbb.com/ → API key al.
/// 2) Not: API key client'ta kalır; prod için proxy önerilir.
class ImgBBUploader implements ImageUploader {
  ImgBBUploader(this.apiKey);
  final String apiKey;

  @override
  Future<String> uploadFile(XFile file) async {
    final bytes = await File(file.path).readAsBytes();
    final b64 = base64Encode(bytes);
    final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    final res = await http.post(uri, body: {'image': b64});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>?;
      final url = data?['display_url'] as String?;
      if (url != null && url.isNotEmpty) return url;
      throw Exception('ImgBB: display_url alınamadı');
    } else {
      throw Exception('ImgBB upload hatası: ${res.statusCode} ${res.body}');
    }
  }
}

/// --------------------
/// Service (tek noktadan kullan)
/// --------------------
class ImageUploadService {
  ImageUploadService._(this.uploader);

  /// Buraya seçtiğin uploader'ı ver.
  static ImageUploadService instance = ImageUploadService._(
    ImgurUploader('YOUR_IMGUR_CLIENT_ID'), // <--- BURAYA Client-ID
    // ImgBBUploader('YOUR_IMGBB_KEY'),
  );

  final ImageUploader uploader;

  Future<String> upload(XFile file) => uploader.uploadFile(file);
}
