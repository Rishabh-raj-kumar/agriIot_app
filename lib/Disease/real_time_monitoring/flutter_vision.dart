import 'package:agriculture/Disease/real_time_monitoring/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// Removed late List<CameraDescription> camerass; (now passed via constructor)

class YoloVideo extends StatefulWidget {
  final FlutterVision vision; // Accept vision instance
  final List<CameraDescription> cameras; // Accept cameras list

  const YoloVideo({
    Key? key,
    required this.vision,
    required this.cameras,
  }) : super(key: key);

  @override
  State<YoloVideo> createState() => _YoloVideoState();
}

class _YoloVideoState extends State<YoloVideo> {
  late CameraController controller;
  // Removed late FlutterVision vision; (now accessed via widget.vision)
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false; // Represents camera initialization status now
  bool isDetecting = false;
  bool _isModalVisible = false; // To track if modal is currently shown
  // Removed confidenceThreshold (using confThreshold in yoloOnFrame)

  // --- Link Generation Logic ---
  // This is a placeholder. You'll need to replace this with your actual logic
  // to get a relevant link based on the detected object's tag.
  String getLinkForObject(String tag) {
    // Example: Generate a Google search link
    return 'https://www.google.com/search?q=${Uri.encodeComponent(tag)}';
    // Or maybe you have a predefined map:
    // Map<String, String> objectLinks = {
    //   "plant_disease_A": "https://example.com/disease_a_info",
    //   "plant_disease_B": "https://example.com/disease_b_info",
    // };
    // return objectLinks[tag] ?? 'https://example.com/not_found';
  }

  // --- URL Launcher Helper ---

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // Use cameras passed from main.dart
    if (widget.cameras.isEmpty) {
      print("No cameras found");
      // Handle case where no cameras are available
      setState(() {
        // Potentially set an error state here
      });
      return;
    }
    controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    try {
      await controller.initialize();
      // Model is already loaded, so we just need the camera to be ready
      setState(() {
        yoloResults = [];
        isLoaded = true; // Camera is loaded
        isDetecting = false;
      });
      print("Camera initialized successfully.");
    } catch (e) {
      print("Error initializing camera: $e");
      // Handle camera initialization error
      // Maybe show a message to the user
    }
  }

  @override
  void dispose() {
    controller.dispose();
    // Don't close the model here if it's loaded globally in main.dart
    // If YoloVideo is the ONLY screen using vision, you might close it here,
    // but it's generally better to manage its lifecycle with the app's lifecycle.
    // await widget.vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          // Changed message as model loading happens earlier
          child: Text("Initializing Camera..."),
        ),
      );
    }

    // Determine scanner border color
    final bool objectDetected = isDetecting && yoloResults.isNotEmpty;
    final Color scannerBorderColor = objectDetected
        ? Colors.green
        : Colors.white; // Green when detecting, white otherwise

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),

          // Bounding Boxes
          ...displayBoxesAroundRecognizedObjects(size),

          // Scanner UI in the Center
          Align(
            alignment: Alignment.center,
            child: Container(
              width: size.width * 0.6, // Example size: 60% of screen width
              height: size.width * 0.6, // Make it square
              decoration: BoxDecoration(
                border: Border.all(
                  color: scannerBorderColor, // Dynamic color
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
            ),
          ),

          // Start/Stop Button (kept original positioning)
          Positioned(
            bottom: 75,
            width: MediaQuery.of(context).size.width,
            child: Center(
              // Center the button horizontally
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 5, color: Colors.white, style: BorderStyle.solid),
                ),
                child: isDetecting
                    ? IconButton(
                        onPressed:
                            stopDetection, // Reference the function directly
                        icon: const Icon(Icons.stop, color: Colors.red),
                        iconSize: 50,
                      )
                    : IconButton(
                        onPressed:
                            startDetection, // Reference the function directly
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        iconSize: 50,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadYoloModel() async {
    // This function is no longer needed here if loading in main.dart
    // If you need to reload for some reason, you could keep it,
    // but initial load should be outside.
    print("Model should be pre-loaded.");
    // Ensure isLoaded reflects camera status, not model status here.
  }

  void _openWebView(String url) {
    if (!mounted) return; // Check mounted state before navigation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(initialUrl: url),
      ),
    );
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    // Use the vision instance passed via the widget
    final result = await widget.vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4, // Adjust as needed
        confThreshold: 0.4, // Adjust as needed
        classThreshold: 0.5 // Adjust as needed
        );

    // Check if mounted before calling setState
    if (!mounted) return;

    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
      // Show modal only if detection results are new and modal isn't already up
      if (!_isModalVisible && isDetecting) {
        _showObjectDetailsModal(yoloResults);
      }
    } else {
      // If results become empty, clear them (optional, based on desired behavior)
      // And allow modal to be shown again next time something is detected
      if (yoloResults.isNotEmpty) {
        // Clear only if it wasn't already empty
        setState(() {
          yoloResults = [];
        });
      }
      // If you want the modal to potentially re-appear if dismissed and object is still there,
      // you might not need to manage _isModalVisible as strictly here, but it helps prevent flicker.
    }
  }

  // --- Function to Show Modal Bottom Sheet ---
  void _showObjectDetailsModal(List<Map<String, dynamic>> detectedObjects) {
    if (detectedObjects.isEmpty || !mounted) return;

    // Get info from the first detected object (you might want to handle multiple)
    final firstObject = detectedObjects[0];
    final String tag = firstObject['tag'];
    final String objectLink = getLinkForObject(tag); // Generate the link
    final double confidence = firstObject['box'][4] * 100;

    // Set flag to prevent multiple modals opening rapidly
    setState(() {
      _isModalVisible = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows modal to take up more height if needed
      shape: const RoundedRectangleBorder(
        // Optional: Rounded corners for modal
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take only necessary height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Object Detected: $tag',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Confidence: ${confidence.toStringAsFixed(1)}%'),
              SizedBox(height: 12),
              InkWell(
                onTap: () => _openWebView(objectLink),
                child: Text(
                  'More Info: $objectLink', // Display the link
                  style: TextStyle(
                    color: Theme.of(context)
                        .primaryColor, // Use theme color for link
                    decoration: TextDecoration.underline,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 20), // Add some padding at the bottom
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Reset the flag when the modal is dismissed
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          _isModalVisible = false;
        });
      }
    });
  }

  Future<void> startDetection() async {
    // Clear previous results when starting a new detection session
    setState(() {
      isDetecting = true;
      yoloResults = []; // Clear results
      _isModalVisible = false; // Ensure modal can show again
    });

    if (controller.value.isStreamingImages) {
      print("Already streaming images.");
      return;
    }

    // Check if camera controller is initialized before starting stream
    if (!controller.value.isInitialized) {
      print("Error: Camera controller not initialized.");
      setState(() {
        isDetecting = false;
      }); // Revert detection state
      return;
    }

    try {
      await controller.startImageStream((image) async {
        if (isDetecting && mounted) {
          // Check mounted state
          cameraImage = image; // Store image for coordinate mapping
          await yoloOnFrame(image); // Perform detection
        }
      });
    } catch (e) {
      print("Error starting image stream: $e");
      setState(() {
        isDetecting = false;
      }); // Revert detection state on error
    }
  }

  Future<void> stopDetection() async {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      isDetecting = false;
      yoloResults.clear();
      _isModalVisible = false; // Hide modal if it was visible
    });

    // Check if controller is initialized and streaming before stopping
    if (controller.value.isInitialized && controller.value.isStreamingImages) {
      try {
        await controller.stopImageStream();
        print("Image stream stopped.");
      } catch (e) {
        print("Error stopping image stream: $e");
      }
    }
    // Optional: Close modal if open when stopping detection
    if (_isModalVisible && Navigator.canPop(context)) {
      Navigator.pop(context); // Dismiss the modal
    }
  }

  // Displays bounding boxes - minor adjustments for clarity
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty || cameraImage == null) return [];

    // Ensure factors handle potential screen orientation vs camera image orientation mismatch
    // This assumes portrait mode where screen width maps to camera height and vice-versa
    // Adjust if your app supports landscape or has different camera orientation setup
    double factorX = screen.width / (cameraImage!.height); // Swapped
    double factorY = screen.height / (cameraImage!.width); // Swapped

    return yoloResults.map((result) {
      // Apply orientation correction if needed. The factors above might handle it.
      // If boxes are still rotated 90 degrees, you might need to swap x/y and width/height
      // calculations based on device orientation or camera sensor orientation.

      double objectX = result["box"][0] * factorX;
      double objectY = result["box"][1] * factorY;
      double objectWidth = (result["box"][2] - result["box"][0]) * factorX;
      double objectHeight = (result["box"][3] - result["box"][1]) * factorY;

      // Optional: Clamp coordinates to screen bounds to prevent overflow errors
      objectX = objectX.clamp(0, screen.width - objectWidth);
      objectY = objectY.clamp(0, screen.height - objectHeight);

      return Positioned(
        left: objectX,
        top: objectY,
        width: objectWidth.abs(), // Use abs in case factors are negative
        height: objectHeight.abs(), // Use abs in case factors are negative
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border:
                Border.all(color: Colors.pink, width: 2.0), // Original border
          ),
          child: Align(
            // Align text to top left
            alignment: Alignment.topLeft,
            child: Container(
              // Container for text background
              color: const Color.fromARGB(
                  180, 50, 233, 30), // Semi-transparent background
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                "${result['tag']} (${(result['box'][4] * 100).toStringAsFixed(1)}%)", // Show confidence %
                style: const TextStyle(
                  color: Colors.black, // Changed text color for better contrast
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0, // Adjusted font size
                ),
                overflow: TextOverflow.ellipsis, // Prevent long text overflow
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
