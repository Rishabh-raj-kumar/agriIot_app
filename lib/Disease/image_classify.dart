import 'dart:io'; // For File class
import 'dart:convert'; // For base64Encode, jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:image_picker/image_picker.dart'; // For picking images

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DetectionPage(),
    );
  }
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  File? _imageFile; // Stores the selected/captured image file
  List<dynamic>? _detections; // Stores detection results from backend
  bool _isLoading = false; // Tracks loading state
  String? _errorMessage; // Stores any error message

  // IMPORTANT: Replace with your computer's actual local IP address
  // where the Flask server is running. Do NOT use localhost or 127.0.0.1
  // if running the Flutter app on a separate device/emulator.
  // Find your IP using 'ipconfig' (Windows) or 'ifconfig'/'ip addr' (macOS/Linux)
  final String _backendUrl = "https://apnikheti.onrender.com/detect";
  // Example: final String _backendUrl = "http://192.168.1.10:5000/detect";

  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = false; // Reset state before picking
      _detections = null;
      _errorMessage = null;
      _imageFile = null;
    });
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        // Automatically start detection after picking
        await _uploadAndDetect();
      } else {
        print('No image selected.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error picking image: $e";
      });
    }
  }

  // Function to upload image and get detections
  Future<void> _uploadAndDetect() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
      _detections = null;
      _errorMessage = null;
    });

    try {
      // 1. Read image bytes
      List<int> imageBytes = await _imageFile!.readAsBytes();

      // 2. Encode bytes to Base64
      String base64Image = base64Encode(imageBytes);

      // 3. Prepare JSON payload
      Map<String, String> body = {'image': base64Image};
      String jsonBody = jsonEncode(body);

      // 4. Make POST request
      print("Sending request to: $_backendUrl");
      final response = await http
          .post(
            Uri.parse(_backendUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonBody,
          )
          .timeout(const Duration(seconds: 60)); // Add timeout

      print("Response Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}"); // Uncomment for debugging

      // 5. Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('detections')) {
          setState(() {
            // Assuming your backend returns a list under the 'detections' key
            _detections = responseData['detections'] as List<dynamic>?;
            if (_detections != null && _detections!.isEmpty) {
              _errorMessage = "No detections found.";
            }
          });
        } else if (responseData.containsKey('error')) {
          setState(() {
            _errorMessage = "Backend Error: ${responseData['error']}";
          });
        } else {
          setState(() {
            _errorMessage = "Unexpected response format from backend.";
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Server Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      print("Error during detection request: $e");
      setState(() {
        _errorMessage = "Network or connection error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detector'),
      ),
      body: SingleChildScrollView(
        // Allows scrolling if content overflows
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image Display Area
              Container(
                width: double.infinity,
                height: 300, // Adjust height as needed
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _imageFile == null
                    ? const Center(child: Text('No Image Selected'))
                    : ClipRRect(
                        // Ensures image stays within rounded borders
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover, // Adjust fit as needed
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Results/Loading/Error Area
              _buildResultsArea(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to display results, loading indicator, or errors
  Widget _buildResultsArea() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      );
    } else if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $_errorMessage',
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );
    } else if (_detections != null) {
      // Display detection results
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey.shade100),
          borderRadius: BorderRadius.circular(8.0),
        ),
        constraints: const BoxConstraints(maxHeight: 200), // Limit height
        child: ListView.builder(
          shrinkWrap: true, // Important inside SingleChildScrollView
          itemCount: _detections!.length,
          itemBuilder: (context, index) {
            final detection = _detections![index] as Map<String, dynamic>;
            final className = detection['class_name'] ?? 'Unknown';
            final confidence =
                (detection['confidence'] as num?)?.toDouble() ?? 0.0;
            // Format confidence as percentage
            final confidencePercent = (confidence * 100).toStringAsFixed(1);

            return ListTile(
              dense: true, // Make list items smaller
              title: Text(className),
              trailing: Text('$confidencePercent%',
                  style: TextStyle(
                      color: confidence > 0.7
                          ? Colors.green
                          : (confidence > 0.4 ? Colors.orange : Colors.red),
                      fontWeight: FontWeight.bold)),
            );
          },
        ),
      );
    } else {
      // Initial state or after clearing
      return const Text('Pick an image to start detection');
    }
  }
}
