// lib/courses/courses_page.dart

import 'package:agriculture/colors.dart';
import 'package:flutter/material.dart';
import './model.dart';
import './data.dart'; // Import dummy data
import 'video_card.dart'; // Import the video card widget

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // State variable for the selected language filter
  VideoCategory _selectedCategory = VideoCategory.english; // Default filter

  // Function to filter videos based on the selected category
  List<Video> _getFilteredVideos() {
    return allVideos
        .where((video) => video.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).primaryColor;
    final filteredVideos = _getFilteredVideos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Videos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Language Filter Dropdown
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: DropdownButton<VideoCategory>(
              value: _selectedCategory,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              elevation: 16,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              underline: Container(height: 0), // Hide the default underline
              dropdownColor:
                  Theme.of(context).primaryColor, // Dropdown background color
              onChanged: (VideoCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
              items: VideoCategory.values.map<DropdownMenuItem<VideoCategory>>(
                  (VideoCategory category) {
                // Convert enum value to a readable string
                String categoryText =
                    category.toString().split('.').last; // 'english' or 'hindi'
                categoryText = categoryText[0].toUpperCase() +
                    categoryText.substring(1); // 'English' or 'Hindi'

                return DropdownMenuItem<VideoCategory>(
                  value: category,
                  child: Text(
                    categoryText,
                    style: const TextStyle(
                        color: Colors
                            .white), // Ensure text is visible on colored background
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: filteredVideos.isEmpty
          ? const Center(
              child: Text(
                'No videos available for this category.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return VideoCard(
                    video:
                        video); // Display each video using the VideoCard widget
              },
            ),
    );
  }
}
