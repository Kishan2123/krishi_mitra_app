import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/upload_service.dart';

class UploadCropPhotoScreen extends StatefulWidget {
  const UploadCropPhotoScreen({super.key});

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Upload successful')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Crop Photo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('No image selected')),
                    ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick Image'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isUploading ? null : _uploadImage,
                    icon: _isUploading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
