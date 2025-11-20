import 'package:flutter/material.dart';

class UploadPreviewCard extends StatelessWidget {
  const UploadPreviewCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Upload Crop Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Take a clear photo of affected leaves, stems, or crops for accurate pest detection.'),
            SizedBox(height: 16),
            Center(
              child: Icon(
                Icons.image,
                size: 100,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}