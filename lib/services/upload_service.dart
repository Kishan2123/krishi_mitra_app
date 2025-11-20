import 'dart:io';

class UploadService {
  Future<Map<String, String>> uploadImage(File image) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Mock API response
    return {
      'status': 'success',
      'message': 'Image uploaded successfully!',
    };
  }
}