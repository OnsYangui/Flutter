import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  Future<String> uploadImage({
    required XFile image,
    required String userId,
    required String type,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final localPath = path.join(directory.path, fileName);
      await image.saveTo(localPath);
      return localPath;
    } catch (e) {
      print('Erreur upload: $e');
      throw Exception('Erreur lors de l\'upload');
    }
  }

  Future<String> uploadPDF({
    required File pdf,
    required String userId,
    required String type,
  }) async {
    return pdf.path;
  }

  Future<List<String>> uploadMultipleImages({
    required List<XFile> images,
    required String userId,
    required String type,
  }) async {
    List<String> paths = [];
    for (var image in images) {
      final url = await uploadImage(
        image: image,
        userId: userId,
        type: type,
      );
      paths.add(url);
    }
    return paths;
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final file = File(fileUrl);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Erreur suppression: $e');
    }
  }

  Future<File> downloadFile(String fileUrl, String fileName) async {
    return File(fileUrl);
  }

  Future<XFile?> takePhoto() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }

  Future<XFile?> pickImageFromGallery() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<List<XFile>> pickMultipleImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    return images;
  }

  Future<File?> pickPDF() async {
    return null;
  }

  Future<File> compressImage(File image) async {
    return image;
  }

  Future<String> getFileSize(String fileUrl) async {
    try {
      final file = File(fileUrl);
      if (await file.exists()) {
        final sizeInBytes = await file.length();
        if (sizeInBytes < 1024) {
          return '$sizeInBytes B';
        } else if (sizeInBytes < 1024 * 1024) {
          return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
        } else {
          return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
        }
      }
      return 'Inconnu';
    } catch (e) {
      return 'Inconnu';
    }
  }
}
