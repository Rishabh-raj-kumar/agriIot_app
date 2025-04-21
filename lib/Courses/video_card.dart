// lib/courses/video_card.dart

import 'package:flutter/material.dart';
import './model.dart';
import './video_detail.dart'; // Import the detail page

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0, // Subtle shadow
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        // Use InkWell for tap effect
        onTap: () {
          // Navigate to the detail page with Hero animation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoDetailPage(video: video),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with Hero Animation
            Hero(
              tag: 'video-thumbnail-${video.id}', // Unique tag for Hero
              child: Image.asset(
                video.thumbnailAssetPath,
                height: 180, // Fixed height for thumbnail
                fit: BoxFit.cover, // Cover the area without distortion
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: Icon(Icons.videocam_off,
                      size: 50, color: Colors.grey[600]),
                  alignment: Alignment.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Title
                  Text(
                    video.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // Limit title lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Video Description Snippet
                  Text(
                    video.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2, // Limit description lines
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
