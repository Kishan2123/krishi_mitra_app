import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';

class UploadCropPhotoScreen extends StatefulWidget {
  const UploadCropPhotoScreen({Key? key}) : super(key: key);

  @override
  State<UploadCropPhotoScreen> createState() => _UploadCropPhotoScreenState();
}

class _UploadCropPhotoScreenState extends State<UploadCropPhotoScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final response = await UploadService().uploadImage(_selectedImage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Upload successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Crop Photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Text('No image selected'),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}