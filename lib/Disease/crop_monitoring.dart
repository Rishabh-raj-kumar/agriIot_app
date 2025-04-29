import 'dart:io';
import 'package:agriculture/Disease/AppleScab.dart';
import 'package:agriculture/Disease/real_time_monitoring/flutter_vision.dart';
import 'package:agriculture/Disease/real_time_monitoring/real_time_object_detection.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_vision/flutter_vision.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // For base64Encode, jsonDecode
import 'package:http/http.dart' as http; // For HTTP request
// --- Placeholder Disease Detail Pages (Replace with your actual pages) ---
// You MUST have these files/classes created for the navigation to work.
// Example: Create 'apple_scab.dart' with 'class AppleDisease extends StatelessWidget...'

import 'package:agriculture/Disease/CornCommonRust.dart';
import 'package:agriculture/Disease/CornGrayLeaf.dart';
import 'package:agriculture/Disease/GrapeLeafBlight.dart';
import 'package:agriculture/Disease/PotatoEarlyBlight.dart';
import 'package:agriculture/Disease/TomatoEarlyBlight.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';

// --- End Page Imports ---
late List<CameraDescription> cameras;
late FlutterVision vision;

const String disclaimerShownKey = 'realTimeDisclaimerShown';

class CropMonitoringPage extends StatefulWidget {
  const CropMonitoringPage({super.key});

  @override
  _CropMonitoringPageState createState() => _CropMonitoringPageState();
}

class _CropMonitoringPageState extends State<CropMonitoringPage> {
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
  // --- Image Picking and Classification Logic ---
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

  Future<void> loadYoloModel() async {
    try {
      await vision.loadYoloModel(
          labels: 'assets/models/classes.txt', // Make sure paths are correct
          modelPath:
              'assets/models/realtime_disease.tflite', // Make sure paths are correct
          modelVersion: "yolov8",
          numThreads: 1, // Adjust as needed
          useGpu: true // Adjust as needed
          );
      print("YOLO Model loaded successfully.");
    } catch (e) {
      print("Error loading YOLO Model: $e");
      // Handle error appropriately - maybe show an error message to the user
    }
  }

  // --- Navigation Logic (Restored from original code) ---
  void _navigateToDiseasePage(String label) {
    // Delay slightly to allow the UI to update before navigating
    Future.delayed(const Duration(milliseconds: 100), () {
      // Ensure context is still mounted before navigating
      if (!mounted) return;

      Widget? targetPage; // Use a nullable Widget

      switch (label) {
        case 'Apple_scab':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppleDisease(),
            ),
          );
          break;
        case 'Cherry_powdery_mildew':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CherryDiseaseDetail(),
            ),
          );
          break;
        case 'Grape_black_rot':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GrapDiseaseDetail(),
            ),
          );
          break;
        case 'Maize_gray_leaf_spot':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CornDisease(),
            ),
          );
          break;
        case 'Potato_Early_blight':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PotatoDiseaseDetail(),
            ),
          );
          break;
        case 'Tomato_Bacterial_spot':
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TomatoDiseaseDetail(),
            ),
          );
          break;
        default:
      }

      // Navigate only if a target page was assigned
      if (targetPage != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage!),
        );
      }
    });
  }

  // --- Real-time Simulation: Bottom Sheet ---

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _navigateToRealTimeDetector() async {
    // 1. Check Camera Permission
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      // 2. Check if disclaimer was shown (using SharedPreferences)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool disclaimerWasShown = prefs.getBool(disclaimerShownKey) ?? false;

      if (!mounted) return; // Check mounted state after

      // 3. Navigate to the screen
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => YoloVideo(vision: vision, cameras: cameras)),
      );

      // 4. Mark disclaimer as shown for future launches
      if (!disclaimerWasShown) {
        await prefs.setBool(disclaimerShownKey, true);
      }
    } else {
      // Permission denied
      _showErrorSnackbar(
          'Camera permission is required for real-time detection.');
      // Optionally guide user to settings using permission_handler's openAppSettings()
      if (cameraStatus.isPermanentlyDenied || cameraStatus.isRestricted) {
        await openAppSettings();
      }
    }
  }

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    init();
    // Initialize FlutterVision
    // Load the YOLO model ONCE here// Load the model when the widget is initialized
  }

  init() async {
    vision = FlutterVision();
    cameras = await availableCameras();

    await loadYoloModel();
  }

  @override
  void dispose() {
    // Release model resources
    super.dispose();
  }

  // --- Build Method (UI Structure) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Optional: Add a subtle gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          // Allows scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Make cards stretch
              children: [
                // --- Card 1: Real-time Monitoring ---
                _buildRealTimeCard(context),
                const SizedBox(height: 20), // Spacing between cards

                // --- Card 2: Image Detection ---
                _buildImageDetectionCard(context),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Card 1 ---
  Widget _buildRealTimeCard(BuildContext context) {
    return InkWell(
      // Make the whole card tappable
      onTap: _navigateToRealTimeDetector, // Navigate on tap
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ]),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, size: 30, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text(
                    'Real-time Crop Monitoring',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Tap here to start live camera detection. Disease information will pop up when identified.', // Updated text
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.9)),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text('Start Monitoring',
                      style: TextStyle(
                          color: Colors.red.shade600,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold)),
                  onPressed: _navigateToRealTimeDetector,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget for Card 2 ---
  Widget _buildImageDetectionCard(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

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
