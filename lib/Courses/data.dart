// lib/courses/dummy_data.dart

import './model.dart';

final List<Video> allVideos = [
  // English Videos
  Video(
    id: 'eng_vid_001',
    title: 'Introduction to Soil Preparation',
    description:
        'Learn the basics of preparing your soil for planting the best crops.',
    videoAssetPath:
        'assets/animations/english/soil_irrigation_eng.mp4', // Replace with actual file name
    thumbnailAssetPath:
        'assets/animations/thumbnail/soil_irrigate.png', // Replace with actual file name
    category: VideoCategory.english,
  ),
  Video(
    id: 'eng_vid_002',
    title: 'Watering Techniques for Drought',
    description: 'Effective methods to water your plants during dry periods.',
    videoAssetPath: 'assets/animations/english/start_farm_eng.mp4', // Replace
    thumbnailAssetPath: 'assets/animations/thumbnail/start_farm.png', // Replace
    category: VideoCategory.english,
  ),
  // Add more English videos...

  // Hindi Videos
  Video(
    id: 'hin_vid_001',
    title: 'मिट्टी तैयार करने का परिचय', // Introduction to Soil Preparation
    description: 'अपनी फसलों के लिए मिट्टी तैयार करने के मूल सिद्धांत सीखें।',
    videoAssetPath:
        'assets/animations/hindi/soil_irrigation_hindi.mp4', // Replace
    thumbnailAssetPath:
        'assets/animations/thumbnail/soil_irrigate.png', // Replace
    category: VideoCategory.hindi,
  ),
  Video(
    id: 'hin_vid_002',
    title: 'सूखे के लिए सिंचाई तकनीकें', // Watering Techniques for Drought
    description: 'सूखे के दौरान अपने पौधों को पानी देने के प्रभावी तरीके।',
    videoAssetPath: 'assets/animations/hindi/start_farm_hindi.mp4', // Replace
    thumbnailAssetPath: 'assets/animations/thumbnail/start_farm.png', // Replace
    category: VideoCategory.hindi,
  ),
  // Add more Hindi videos...
];
