import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, String>> _photos = List.generate(
    8,
    (index) => {
      'image': 'assets/images/uploads/3b626cd8-3bc5-4b85-97a6-271f133cacab.png',
      'author': index.isEven ? 'Rekha (Ranchi)' : 'Mohan (Hazaribagh)',
      'caption': index.isEven ? 'New paddy transplant. Any tips for weed control?' : 'Organic brinjal doing well this week!',
    },
  );

  void _openDetail(Map<String, String> photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(photo['image']!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(photo['author']!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(photo['caption']!, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.thumb_up_alt_outlined, size: 18),
                SizedBox(width: 8),
                Text('Appreciate', style: TextStyle(fontWeight: FontWeight.w600)),
                Spacer(),
                Icon(Icons.comment_outlined, size: 18),
                SizedBox(width: 8),
                Text('Discuss'),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Community Feed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push('/upload-crop-photo'),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Upload crop photo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Photos from farmers around Jharkhand'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4 / 3,
            ),
            itemCount: _photos.length,
            itemBuilder: (context, index) {
              final photo = _photos[index];
              return GestureDetector(
                onTap: () => _openDetail(photo),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(photo['image']!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(photo['author']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(photo['caption']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
