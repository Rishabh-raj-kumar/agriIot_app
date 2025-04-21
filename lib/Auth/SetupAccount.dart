import 'package:agriculture/Home/home.dart'; // Make sure this path is correct
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Optional: Add google_fonts for better typography

import 'package:shared_preferences/shared_preferences.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Dispose controllers when the widget is removed from the tree
  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(user.uid)
              .set({
            'username': _usernameController.text.trim(),
            'fullname': _fullnameController.text.trim(),
            'location': _locationController.text.trim(),
            'email': _emailController.text.trim(),
            // You might want to add a timestamp
            'createdAt': FieldValue.serverTimestamp(),
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', _usernameController.text.trim());
          await prefs.setString('email', _emailController.text.trim());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile created successfully!',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green[700], // Success color
              behavior: SnackBarBehavior.floating, // Optional: make it float
            ),
          );

          // Navigate to HomePage and replace the current route
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // Ensure HomePage constructor matches what it expects
              builder: (context) => HomePage(
                initialTask: [], // Pass required arguments
              ),
            ),
          );
        } else {
          // Handle case where user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not logged in.',
                  style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.redAccent, // Error color
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Maybe navigate to login page
        }
      } catch (e) {
        print(
            'Error creating profile: $e'); // Print error to console for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile. Please try again.',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent, // Error color
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a clean AppBar with a relevant background color
      appBar: AppBar(
        title: Text(
          'Create Your Profile',
          // Apply a clean, possibly bold font
          style: GoogleFonts.roboto(
            // Example using Roboto from google_fonts
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[800], // Darker green for industrial feel
        elevation: 4.0, // Subtle shadow
        centerTitle: true, // Center the title
      ),
      body: Container(
        // Optional: Add a subtle background or pattern related to agriculture
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/farm_background.jpg'), // Replace with your image
        //     fit: BoxFit.cover,
        //     opacity: 0.1, // Make it subtle
        //   ),
        // ),
        color: Colors.grey[50], // Light gray background for contrast
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Center(
          // Center the form content
          child: SingleChildScrollView(
            // Allow scrolling if content overflows
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch inputs horizontally
                children: [
                  // Optional: Add an icon or logo
                  Icon(
                    Icons
                        .account_circle_outlined, // Or an agriculture-related icon
                    size: 80,
                    color: Colors.green[700],
                  ),
                  const SizedBox(height: 24),

                  // Modernized TextFormField with OutlineInputBorder
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a unique username',
                      prefixIcon: Icon(Icons.person_outline,
                          color: Colors.grey[600]), // Icon
                      border: OutlineInputBorder(
                        // Modern border
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide.none, // No visible border line initially
                      ),
                      filled: true, // Add fill color
                      fillColor: Colors.white, // White background for inputs
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 12.0), // Adjust padding
                      // Customize focused border color
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.green[700]!, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        // Style error border
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        // Style focused error border
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16), // Spacing between fields

                  TextFormField(
                    controller: _fullnameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon:
                          Icon(Icons.badge_outlined, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 12.0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.green[700]!, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g., Your City, State/Province',
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 12.0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.green[700]!, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon:
                          Icon(Icons.email_outlined, color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 12.0),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.green[700]!, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide:
                            BorderSide(color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                    keyboardType:
                        TextInputType.emailAddress, // Set keyboard type
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      // Optional: Add more robust email validation
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30), // Increased spacing before button

                  // Styled Elevated Button
                  ElevatedButton(
                    onPressed: _submitProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0), // Button padding
                      backgroundColor:
                          Colors.green[700], // Button background color
                      foregroundColor: Colors.white, // Button text color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded corners
                      ),
                      elevation: 4.0, // Subtle shadow for the button
                    ),
                    child: Text(
                      'Create Profile',
                      style: GoogleFonts.roboto(
                        // Apply font to button text
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spacing after button

                  // Optional: Add a subtle footer or app version info
                  Text(
                    'App Version 1.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
