// lib/screens/about_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  // Function to launch a URL

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // If the URL can't be launched, show an error (e.g., a SnackBar)
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Developer Image (Optional)
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    const AssetImage('assets/images/rishabh_photo.jpg'),
                onBackgroundImageError: (e, stacktrace) {
                  // Handle image loading errors
                  print('Error loading developer image: $e');
                },
              ),
            ),
            const SizedBox(height: 20.0),

            // Developer Name (Optional)
            const Center(
              child: Text(
                'Rishabh Raj', // Replace with your name
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Description
            const Text(
              'About Me', // Section Title
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Hi there! I\'m Rishabh Raj, the developer behind this Farmer Marketplace app. My goal is to empower farmers by providing a platform to connect, access services, and thrive. I am passionate about using technology to solve real-world problems in agriculture.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const SizedBox(height: 24.0),

            // Social Media Links
            const Text(
              'Connect with Me', // Section Title
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Example Social Link 1 (LinkedIn)
            ListTile(
              leading:
                  const Icon(Icons.link, color: Colors.blue), // Example icon
              title: const Text('LinkedIn'),
              subtitle: const Text(
                  'LinkedIn Profile'), // Replace with your profile name/handle
              onTap: () => _launchUrl(
                  'https://www.linkedin.com/in/rishabh-raj-225681274/'), // Replace with your LinkedIn URL
            ),
            const Divider(), // Optional visual separator

            // Example Social Link 2 (GitHub)
            ListTile(
              leading:
                  const Icon(Icons.code, color: Colors.black87), // Example icon
              title: const Text('GitHub'),
              subtitle: const Text(
                  'GitHub Profile'), // Replace with your profile name/handle
              onTap: () => _launchUrl(
                  'https://github.com/Rishabh-raj-kumar'), // Replace with your GitHub URL
            ),
            const Divider(),

            // Example Social Link 3 (Twitter/X - using a generic icon)
            ListTile(
              leading: const Icon(Icons.mail,
                  color: Colors.blueAccent), // Using mail icon as example
              title: const Text('Twitter / X'),
              subtitle: const Text('@minehandle'), // Replace with your handle
              onTap: () => _launchUrl(
                  'https://twitter.com/yourhandle'), // Replace with your Twitter/X URL
            ),
            const Divider(),

            // Add more ListTile widgets for other social media links (Facebook, personal website, etc.)
            const SizedBox(height: 20.0),

            const Center(
              child: Text(
                '© 2025 AgriIot/Company. All rights reserved.', // Replace with your details
                style: TextStyle(fontSize: 12.0, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
