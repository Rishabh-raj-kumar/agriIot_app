import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Remove Firebase Storage import
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';
import 'package:appwrite/appwrite.dart'; // Import Appwrite SDK
import '../model/service_model.dart' as app_service;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Appwrite Configuration ---'
// Replace with your actual Appwrite project details
var appwriteEndpoint =
    dotenv.env['AppwriteEndpoint']; // e.g., 'https://cloud.appwrite.io/v1'
var appwriteProjectId = dotenv.env['AppwriteProjectId'];
var appwriteBucketId = dotenv.env['AppwriteBucketId'];
// --- End Appwrite Configuration ---

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({Key? key}) : super(key: key);

  @override
  _AddServiceScreenState createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  // ... (keep other controllers: _titleController, _descriptionController, etc.)
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  String _selectedPriceUnit = 'kg';
  File? _imageFile;
  LatLng? _serviceLocation;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final Location _locationService = Location();

  // --- Appwrite Client Initialization ---
  late Client _appwriteClient;
  late Storage _appwriteStorage;

  @override
  void initState() {
    super.initState();
    // Initialize Appwrite Client and Storage
    _appwriteClient = Client()
          ..setEndpoint(appwriteEndpoint!)
          ..setProject(appwriteProjectId)
        // ..setSelfSigned(status: true); // Only if using self-signed certificate
        ;
    _appwriteStorage = Storage(_appwriteClient);
  }
  // --- End Appwrite Client Initialization ---

  // --- Keep _pickImage and _getCurrentLocation functions as they were ---
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery); // Or ImageSource.camera
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      // ... (location permission and fetching logic remains the same) ...
      final LocationData locationData = await _locationService.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _serviceLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location set to current location.')),
        );
      } else {/* handle error */}
    } catch (e) {/* handle error */} finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UPDATED: Function to upload image to Appwrite Storage ---
  Future<String?> _uploadImageToAppwrite(File imageFile) async {
    try {
      // Create a unique file ID
      final fileId = ID.unique();
      // Prepare the file for upload
      final inputFile = InputFile.fromPath(
        path: imageFile.path,
        filename:
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}', // Optional: provide a filename
      );

      // Upload the file
      final appwriteFile = await _appwriteStorage.createFile(
          bucketId: appwriteBucketId!,
          fileId: fileId, // Use the unique ID
          file: inputFile,
          permissions: [
            Permission.read(Role.any()), // Grant public read access
            // Alternatively, grant access to specific users/teams if needed:
            // Permission.read(Role.user('USER_ID')),
          ]);

      // --- Construct the public URL ---
      // This URL allows viewing the file if read permissions are set correctly
      final imageUrl =
          '$appwriteEndpoint/storage/buckets/$appwriteBucketId/files/${appwriteFile.$id}/view?project=$appwriteProjectId';

      print('Appwrite File ID: ${appwriteFile.$id}');
      print('Appwrite Image URL: $imageUrl');

      return imageUrl;
    } on AppwriteException catch (e) {
      // Catch specific Appwrite exceptions
      print("Appwrite Storage Error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appwrite image upload failed: ${e.message}')),
      );
      return null;
    } catch (e) {
      // Catch any other errors
      print("Image Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
      return null;
    }
  }

  // --- UPDATED: _submitService to use Appwrite upload function ---
  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      /* show error */ return;
    }
    if (_serviceLocation == null) {
      /* show error */ return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload image to Appwrite
      String? imageUrl = await _uploadImageToAppwrite(
          _imageFile!); // Call the updated function
      if (imageUrl == null) {
        throw Exception(
            "Failed to upload image to Appwrite."); // Stop if upload fails
      }

      // 2. Create Service object (using the aliased import)
      final newService = app_service.Service(
        // id is generated by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        priceUnit: _selectedPriceUnit,
        imageUrl: imageUrl, // Use the Appwrite image URL
        rating: 0.0,
        sellerName: _sellerNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        location: _serviceLocation!,
      );

      // 3. Save metadata to Firestore (this part remains unchanged)
      await FirebaseFirestore.instance
          .collection('services')
          .add(newService.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service added successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Service Submission Error: $e"); // Log Firestore or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add service: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // ... dispose controllers ...
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _sellerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service'),
        // backgroundColor: Colors.green[700], // Theme
      ),
      body: Stack(
        // Use Stack to show loading indicator over the form
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                // Use ListView for scrollability
                children: [
                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                        labelText: 'Service Title',
                        border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Price and Unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixText: '\₹'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'))
                          ], // Allow digits and decimal
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Enter price';
                            if (double.tryParse(value) == null)
                              return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriceUnit,
                          decoration: const InputDecoration(
                              labelText: 'Unit', border: OutlineInputBorder()),
                          items: ['kg', 'bunch', 'litre', 'item', 'hour', 'day']
                              .map((unit) => DropdownMenuItem(
                                  value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPriceUnit = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Seller Name
                  TextFormField(
                    controller: _sellerNameController,
                    decoration: const InputDecoration(
                        labelText: 'Your Name / Business Name',
                        border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Contact Number
                  TextFormField(
                      controller: _contactNumberController,
                      decoration: const InputDecoration(
                          labelText: 'WhatsApp Contact Number',
                          border: OutlineInputBorder(),
                          prefixText: '+91 '), // Example prefix
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Enter contact number';
                        if (value.length < 10)
                          return 'Enter a valid number'; // Basic check
                        return null;
                      }),
                  const SizedBox(height: 20),

                  // Image Picker
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    Image.file(_imageFile!, fit: BoxFit.cover))
                            : const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Select Image'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black87)),
                    ],
                  ),
                  if (_imageFile == null) // Show validation hint inline
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Please select an image',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12)),
                    ),
                  const SizedBox(height: 20),

                  // Location Setter
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: _serviceLocation != null
                              ? Colors.green
                              : Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            _serviceLocation != null
                                ? 'Location Set: (${_serviceLocation!.latitude.toStringAsFixed(4)}, ${_serviceLocation!.longitude.toStringAsFixed(4)})'
                                : 'Service Location Not Set',
                            style: TextStyle(
                                color: _serviceLocation != null
                                    ? Colors.black87
                                    : Colors.grey[600])),
                      ),
                      TextButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Use Current'),
                      ),
                    ],
                  ),
                  if (_serviceLocation == null) // Show validation hint inline
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Please set the service location',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12)),
                    ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _submitService, // Disable button when loading
                    child: const Text('Add Service'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      //  backgroundColor: Colors.green[600], // Theme
                      //  foregroundColor: Colors.white, // Theme
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Indicator Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
