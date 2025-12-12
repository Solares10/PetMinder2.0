import 'dart:convert';
import 'dart:typed_data';
import 'package:petminder_flutter/config/api_keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:http/http.dart' as http;

/// Uploads an image to imgBB and returns the image URL.
Future<String?> pickAndUploadPetImage() async {
  try {
    Uint8List? imageBytes;
    String? fileName;

    // ---------------- WEB UPLOAD ----------------
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.first.bytes == null) {
        return null;
      }

      imageBytes = result.files.first.bytes!;
      fileName = result.files.first.name;
    }

    // ---------------- MOBILE UPLOAD ----------------
    else {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) return null;

      final file = File(picked.path);
      imageBytes = await file.readAsBytes();
      fileName = picked.name;
    }

    // Convert to base64
    String base64Image = base64Encode(imageBytes!);

    // Send POST to imgBB
    final url =
        Uri.parse("https://api.imgbb.com/1/upload?key=${ApiKeys.imgbbKey}");
    final response = await http.post(url, body: {
      "image": base64Image,
      "name": fileName,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["data"]?["url"] != null) {
      return data["data"]["url"]; // ⭐ Return usable image URL
    } else {
      print("Upload failed: $data");
      return null;
    }
  } catch (e) {
    print("ERROR uploading image: $e");
    return null;
  }
}
