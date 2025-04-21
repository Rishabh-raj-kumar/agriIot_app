// lib/screens/add_service_screen.dart

import 'package:flutter/material.dart';
import './service.dart'; // Import the Service model
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  // We keep the imageUrlController for demonstration, but the picked image will take precedence in the UI
  final TextEditingController _imageUrlController = TextEditingController();

  // Variable to store the picked image file
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  // Simple dropdown options for demonstration
  final List<String> _categories = [
    'Machinery',
    'Pest Control',
    'Consulting',
    'Maintenance',
    'Other'
  ];
  String? _selectedCategory;

  final List<String> _locations = [
    'Rural Area A',
    'Rural Area B',
    'Rural Area C',
    'Other'
  ];
  String? _selectedLocation;

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery); // Or ImageSource.camera

    if (selectedImage != null) {
      setState(() {
        _pickedFile = selectedImage;
        // Optional: Clear the image URL field if an image is picked
        _imageUrlController.clear();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _submitService() {
    if (_formKey.currentState!.validate()) {
      // In a real application:
      // 1. Upload the _pickedFile to cloud storage (Firebase Storage, AWS S3, etc.)
      // 2. Get the downloadable URL of the uploaded image.
      // 3. Use this URL when creating the Service object.
      // For this example, we'll demonstrate displaying the picked image locally
      // and use the _imageUrlController text if no image was picked.
      // The Service model still expects a URL.

      String finalImageUrl = _pickedFile != null
          ? 'file://${_pickedFile!.path}' // Use local file path as URL prefix for display
          : (_imageUrlController.text.trim().isEmpty
              ? 'https://via.placeholder.com/150' // Default placeholder if no image/URL
              : _imageUrlController.text
                  .trim()); // Use provided URL if available

      // Note: The 'file://' URL is ONLY for displaying local files in Image.network.
      // It will NOT work if you actually try to fetch it remotely.
      // In a real app, this would be the *uploaded* image's public URL.

      final newService = Service(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        pricePerHour: double.parse(_priceController.text),
        rating: 0.0, // New services could start with 0 or no rating
        category: _selectedCategory ?? _categoryController.text.trim(),
        location: _selectedLocation ?? _locationController.text.trim(),
        imageUrl: finalImageUrl, // Use the determined image URL
        comments: [], // New service starts with no comments
      );

      Navigator.pop(context, newService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Selection Area
              const Text('Service Image:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _pickedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(_pickedFile!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey[600]),
                            const SizedBox(height: 8.0),
                            Text(
                              'Tap to select image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Optional Image URL field (if no image is picked)
              TextFormField(
                controller: _imageUrlController,
                enabled: _pickedFile == null, // Disable if an image is picked
                decoration: InputDecoration(
                  labelText: 'Or enter Image URL (Optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16.0),

              // Service Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter service name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Service Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Price per Hour
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price per Hour (\$)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) < 0) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Category (Dropdown + Optional Text Input)
              const Text('Category:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                value: _selectedCategory,
                hint: const Text('Select Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    if (newValue != 'Other') _categoryController.clear();
                  });
                },
                validator: (value) {
                  if (value == null &&
                      _categoryController.text.trim().isEmpty) {
                    return 'Please select or enter a category';
                  }
                  if (value == 'Other' &&
                      _categoryController.text.trim().isEmpty) {
                    return 'Please enter a category name for "Other"';
                  }
                  return null;
                },
              ),
              if (_selectedCategory == 'Other') ...[
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Enter Custom Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: (value) {
                    if (_selectedCategory == 'Other' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16.0),

              // Location (Dropdown + Optional Text Input)
              const Text('Location:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                value: _selectedLocation,
                hint: const Text('Select Location'),
                items: _locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLocation = newValue;
                    if (newValue != 'Other') _locationController.clear();
                  });
                },
                validator: (value) {
                  if (value == null &&
                      _locationController.text.trim().isEmpty) {
                    return 'Please select or enter a location';
                  }
                  if (value == 'Other' &&
                      _locationController.text.trim().isEmpty) {
                    return 'Please enter a location name for "Other"';
                  }
                  return null;
                },
              ),
              if (_selectedLocation == 'Other') ...[
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter Custom Location',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  validator: (value) {
                    if (_selectedLocation == 'Other' &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a location name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24.0),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitService,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    backgroundColor: Colors.green[700], // Button color
                    foregroundColor: Colors.white, // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Add Service'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
