// lib/courses/models.dart

enum VideoCategory {
  english,
  hindi,
}

class Video {
  final String id; // Unique ID for Hero tag and future use
  final String title;
  final String description;
  final String
      videoAssetPath; // Path like 'assets/animation/english/video1.mp4'
  final String
      thumbnailAssetPath; // Path like 'assets/thumbnails/video1_thumb.png'
  final VideoCategory category;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoAssetPath,
    required this.thumbnailAssetPath,
    required this.category,
  });
}
