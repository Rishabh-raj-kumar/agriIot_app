// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_v2/tflite_v2.dart';
// import 'dart:math' as math;

// // --- IMPORTANT: You need to download these files and put them in assets/models/ ---
// // Example: ssd_mobilenet_v1_1_metadata.tflite and labels.txt
// // const String tfliteModelPath =
//     "assets/models/my_model_int8.tflite"; // Make sure this path is correct
// const String labelsPath =
//     "assets/models/classes.txt"; // Make sure this path is correct
// // -----------------------------------------------------------------------------

// class ObjectDetectionScreen extends StatefulWidget {
//   @override
//   _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
// }

// class _ObjectDetectionScreenState extends State<ObjectDetectionScreen>
//     with WidgetsBindingObserver {
//   CameraController? _controller;
//   List<CameraDescription>? cameras;
//   List<dynamic>? _recognitions; // Using dynamic as returned by tflite_v2

//   bool _isCameraInitialized = false;
//   bool _isModelLoaded = false;
//   bool _isDetecting = false;

//   // Flags to indicate if initialization/loading failed
//   bool _cameraInitializationFailed = false;
//   bool _modelLoadingFailed = false;

//   // Parameters for frame throttling
//   int _frameInterval =
//       200; // Process a frame roughly every 200 milliseconds (5 fps)
//   DateTime _lastDetectionTime = DateTime.now();

//   // Store camera image dimensions used for detection input
//   // These are the dimensions of the raw frames from the camera,
//   // NOT necessarily the input size of the model if you were using tflite_flutter
//   int _imageHeight = 0;
//   int _imageWidth = 0;

//   // Store preview size and position for overlay calculations
//   Size? _previewSize;
//   Offset? _previewPosition;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     // Start initialization and model loading asynchronously
//     _initializeCamera();
//     _loadModel();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller?.dispose().then((_) {
//       print("Camera controller disposed");
//     }).catchError((e) {
//       print("Error disposing camera controller: $e");
//     });
//     Tflite.close(); // Close TFLite model resources
//     print("TFLite closed");
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final CameraController? cameraController = _controller;

//     // If camera controller is not initialized, do nothing
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return;
//     }

//     // Handle app lifecycle changes
//     if (state == AppLifecycleState.inactive) {
//       // Pause video stream when app is inactive
//       cameraController
//           .stopImageStream()
//           .catchError((e) => print("Error stopping stream: $e"));
//     } else if (state == AppLifecycleState.resumed) {
//       // Resume video stream when app is resumed
//       // Only start stream if it was previously stopped (e.g., due to inactive state)
//       if (!cameraController.value.isStreamingImages) {
//         cameraController.startImageStream((CameraImage image) {
//           _detectObjects(image);
//         }).catchError((e) => print("Error starting stream: $e"));
//       }
//     }
//   }

//   Future<void> _initializeCamera() async {
//     // Use a flag to prevent multiple initializations if called more than once
//     if (_isCameraInitialized || _cameraInitializationFailed || !mounted) {
//       return;
//     }

//     try {
//       cameras = await availableCameras();
//       if (!mounted) return; // Check mounted after await

//       if (cameras == null || cameras!.isEmpty) {
//         print("No cameras available");
//         if (mounted) {
//           setState(() {
//             _cameraInitializationFailed = true; // Set failed flag
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('No cameras available on this device.')),
//           );
//         }
//         return; // Stop initialization if no cameras
//       }

//       // Select the first available camera (usually back camera)
//       // Consider using ResolutionPreset.medium or low for better performance on detection
//       _controller = CameraController(cameras![0], ResolutionPreset.medium,
//           enableAudio: false);

//       await _controller!.initialize();

//       if (!mounted) return; // Check mounted after await

//       // Store actual dimensions of the camera image feed
//       // These are the dimensions of the frames being processed by _detectObjects
//       _imageHeight = _controller!.value.previewSize!.height.toInt();
//       _imageWidth = _controller!.value.previewSize!.width.toInt();

//       // Start image stream AFTER initialization is complete and successful
//       _controller!.startImageStream((CameraImage image) {
//         _detectObjects(image);
//       });

//       // Update state to indicate camera is initialized successfully
//       if (mounted) {
//         setState(() {
//           _isCameraInitialized = true;
//         });
//       }
//     } catch (e) {
//       print("Error initializing camera: $e");
//       if (mounted) {
//         setState(() {
//           _cameraInitializationFailed = true; // Set failed flag on error
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error initializing camera: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   Future<void> _loadModel() async {
//     // Use a flag to prevent multiple loading attempts
//     if (_isModelLoaded || _modelLoadingFailed || !mounted) {
//       return;
//     }

//     try {
//       // Load the TFLite model from assets
//       // Use the correct model parameter string based on the plugin's requirements
//       // for standard models (like "SSDMobileNet") or provide the model path
//       // if the plugin supports loading custom models this way.
//       // Given tflite_v2 and the error "SSDMobileNet" was used before,
//       // let's try loading the path but keep in mind tflite_v2 detectObjectOnFrame
//       // is specific.
//       String? res = await Tflite.loadModel(
//         model: tfliteModelPath, // Path to your custom model
//         labels: labelsPath,
//         // numThreads: 1, // Optional: Set number of threads
//         // isAsset: true, // default is true if path doesn't start with '/'
//         // useGpuDelegate: false, // Set to true if you have GPU delegate model and want to use it
//         // useNnapiDelegate: false, // Set to true for NNAPI delegate on Android
//       );
//       print("Model loading result: $res");

//       if (!mounted) return; // Check mounted after await

//       if (res != null && res == "success") {
//         setState(() {
//           _isModelLoaded = true; // Set loaded flag
//         });
//       } else {
//         // Model loading failed for some reason (res is null or not "success")
//         print("Failed to load model: Result was not 'success'.");
//         setState(() {
//           _modelLoadingFailed = true; // Set failed flag
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Failed to load TFLite model. Check paths and files.')),
//         );
//       }
//     } catch (e) {
//       print("Error loading model: $e");
//       if (mounted) {
//         setState(() {
//           _modelLoadingFailed = true; // Set failed flag on error
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading model: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   Future<void> _detectObjects(CameraImage image) async {
//     // Implement frame throttling
//     final now = DateTime.now();
//     if (_isDetecting ||
//         !_isModelLoaded ||
//         !_isCameraInitialized ||
//         _cameraInitializationFailed || // Don't detect if camera failed
//         _modelLoadingFailed || // Don't detect if model failed
//         now.difference(_lastDetectionTime).inMilliseconds < _frameInterval) {
//       return; // Skip frame if busy, not ready, failed, or interval hasn't passed
//     }

//     _isDetecting = true; // Set flag to indicate processing
//     _lastDetectionTime = now; // Update last detection time

//     try {
//       // --- IMPORTANT with tflite_v2 ---
//       // The 'detectObjectOnFrame' method in tflite_v2 is designed to work
//       // with specific, pre-defined model architectures like SSD MobileNet
//       // or specific YOLO versions that output tensors in a format it understands.
//       // If 'model_custom.tflite' is a custom-trained model (especially YOLOv8),
//       // its output format is very likely NOT compatible with 'detectObjectOnFrame'.
//       // This will cause errors (like the IllegalArgumentException you saw)
//       // or simply return no recognitions.

//       // If you must use 'model_custom.tflite' (e.g., a YOLOv8 model), you should
//       // use the 'tflite_flutter' package and manually parse the output tensors
//       // as discussed in the previous turn.

//       // For this code using tflite_v2, if model_custom.tflite IS NOT a standard
//       // SSD MobileNet, this call might still fail or give bad results.
//       // If it IS a standard SSD MobileNet loaded by path, using model: "SSDMobileNet"
//       // here *might* work as the plugin recognizes the type, but it's safer
//       // to use a model explicitly known to work with this method.

//       var recognitions = await Tflite.detectObjectOnFrame(
//           bytesList: image.planes.map((plane) {
//             return plane.bytes;
//           }).toList(),
//           // If using a standard SSD MobileNet loaded via path, try "SSDMobileNet"
//           // If using a different model, this method is likely not suitable.
//           // Keep the model parameter as the path as a common pattern, but be warned.
//           model: tfliteModelPath, // Use the model path loaded
//           imageHeight: _imageHeight, // Dimensions of the frame being processed
//           imageWidth: _imageWidth,
//           rotation:
//               90, // Adjust based on camera/device orientation and model training
//           numResultsPerClass: 5, // How many top detections per class to return
//           threshold: 0.5, // Confidence threshold (0.0 to 1.0)
//           asynch: true // Run detection asynchronously
//           );

//       // Update UI if the widget is still mounted
//       if (mounted) {
//         setState(() {
//           _recognitions = recognitions; // Update the detection results
//         });
//       }
//     } catch (e) {
//       print("Error during object detection inference: $e");
//       // This try-catch helps catch errors during the actual inference step
//       if (mounted) {
//         // Optionally show a temporary error message for inference issues
//       }
//     } finally {
//       _isDetecting = false; // Reset flag after detection attempt
//     }
//   }

//   // --- Calculate the size and position of the camera preview on the screen ---
//   // This is crucial for correctly positioning the detection overlay bounding boxes.
//   void _updatePreviewSizeAndPosition(BuildContext context) {
//     // Only calculate if camera controller is initialized
//     if (_controller == null || !_controller!.value.isInitialized) {
//       _previewSize = null;
//       _previewPosition = null;
//       return;
//     }

//     final Size screen = MediaQuery.of(context).size;
//     final Size preview = _controller!
//         .value.previewSize!; // Get preview size from controller value

//     // Calculate the aspect ratio of the camera preview frames.
//     // This is the aspect ratio in the orientation the frames are delivered.
//     // The CameraPreview widget handles the visual rotation for display.
//     // We calculate how this aspect ratio fits into the screen's aspect ratio.
//     double previewAspectRatio = preview.width / preview.height;

//     double screenAspectRatio = screen.width / screen.height;

//     double calculatedPreviewWidth;
//     double calculatedPreviewHeight;
//     double calculatedPreviewTop = 0;
//     double calculatedPreviewLeft = 0;

//     // Determine the size and position based on fitting the camera preview
//     // into the available screen space while maintaining its aspect ratio.
//     if (previewAspectRatio > screenAspectRatio) {
//       // Camera preview frames are wider than the screen's aspect ratio when displayed.
//       // Fit the preview height to the screen height, and calculate the width.
//       calculatedPreviewHeight = screen.height;
//       calculatedPreviewWidth = screen.height * previewAspectRatio;
//       calculatedPreviewLeft =
//           (screen.width - calculatedPreviewWidth) / 2; // Center horizontally
//       calculatedPreviewTop = 0;
//     } else {
//       // Camera preview frames are taller than the screen's aspect ratio when displayed.
//       // Fit the preview width to the screen width, and calculate the height.
//       calculatedPreviewWidth = screen.width;
//       calculatedPreviewHeight = screen.width / previewAspectRatio;
//       calculatedPreviewTop =
//           (screen.height - calculatedPreviewHeight) / 2; // Center vertically
//       calculatedPreviewLeft = 0;
//     }

//     // Store the calculated size and position where the camera preview widget will be displayed.
//     _previewSize = Size(calculatedPreviewWidth, calculatedPreviewHeight);
//     _previewPosition = Offset(calculatedPreviewLeft, calculatedPreviewTop);

//     // Note: We don't call setState here to avoid infinite loops, as this method
//     // is typically called during the build cycle.
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Update preview size and position *before* building the layout using these values.
//     _updatePreviewSizeAndPosition(context);

//     // Determine what to display based on initialization and loading states
//     Widget bodyContent;

//     if (!_isCameraInitialized ||
//         !_isModelLoaded ||
//         _cameraInitializationFailed ||
//         _modelLoadingFailed) {
//       // Show loading/error state if camera or model is not ready or failed
//       bodyContent = Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (!_isCameraInitialized &&
//               !_cameraInitializationFailed) // Show camera loading unless failed
//             const CircularProgressIndicator(),
//           if (!_isModelLoaded &&
//               !_modelLoadingFailed) // Show model loading unless failed
//             const CircularProgressIndicator(),

//           const SizedBox(height: 16),

//           if (_cameraInitializationFailed)
//             const Text("Camera initialization failed."),
//           if (_modelLoadingFailed)
//             const Text(
//                 "Model loading failed.\nCheck asset paths and model compatibility."),
//           if (!_isCameraInitialized && !_cameraInitializationFailed)
//             const Text("Initializing Camera..."),
//           if (!_isModelLoaded && !_modelLoadingFailed)
//             const Text("Loading Model..."),
//           if (!_isCameraInitialized &&
//               !_cameraInitializationFailed &&
//               cameras != null &&
//               cameras!.isEmpty)
//             const Text(
//                 "No cameras found.") // Specific message if no cameras were listed
//         ],
//       ));
//     } else {
//       // Show camera preview and detection overlay if everything is initialized
//       // Widget to display the camera preview
//       Widget cameraWidget = CameraPreview(_controller!);

//       // Apply scaling and positioning to the CameraPreview widget
//       // This ensures the CameraPreview is displayed correctly and the overlay
//       // can be drawn aligned with it.
//       if (_previewSize != null) {
//         cameraWidget = SizedBox(
//           // Use SizedBox to give FittedBox constraints
//           width: _previewSize!.width,
//           height: _previewSize!.height,
//           child: FittedBox(
//             fit: BoxFit
//                 .cover, // Ensures the preview fills the area maintaining aspect ratio
//             child: SizedBox(
//               // Inner box size matches camera feed dimensions
//               width: _controller!.value.previewSize!.width,
//               height: _controller!.value.previewSize!.height,
//               child: cameraWidget,
//             ),
//           ),
//         );
//       } else {
//         // Fallback if preview size couldn't be calculated (shouldn't happen if _isCameraInitialized is true)
//         cameraWidget = Center(child: cameraWidget); // Center the preview
//       }

//       bodyContent = Stack(
//         children: [
//           // Position the camera preview widget correctly
//           if (_previewPosition !=
//               null) // Only position if calculation was successful
//             Positioned(
//               top: _previewPosition!.dy,
//               left: _previewPosition!.dx,
//               width: _previewSize!.width,
//               height: _previewSize!.height,
//               child: cameraWidget,
//             )
//           else // Fallback if positioning failed (shouldn't happen)
//             cameraWidget,

//           // Overlay for detections, positioned relative to the screen
//           _buildOverlay(),
//         ],
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text("Real-Time Object Detection")),
//       body: bodyContent, // Display the calculated body content
//     );
//   }

//   // --- Widget to draw bounding boxes and labels ---
//   Widget _buildOverlay() {
//     // Ensure we have detections and valid preview information before drawing overlay
//     // _recognitions is from tflite_v2 detectObjectOnFrame
//     if (_recognitions == null ||
//             _recognitions!.isEmpty ||
//             _previewSize == null ||
//             _previewPosition == null ||
//             _imageWidth == 0 ||
//             _imageHeight == 0 // Ensure image dimensions are also known
//         ) {
//       return Container(); // Return empty container if nothing to draw or info is missing
//     }

//     // Scaling factors: normalized coordinates (0 to 1) from model output
//     // need to be scaled by the dimensions of the image *fed to the model*
//     // and then mapped to the size and position of the CameraPreview widget on screen.
//     // tflite_v2's detectObjectOnFrame returns coordinates normalized (0-1) relative to the
//     // imageWidth and imageHeight *passed to the method*.

//     // These coordinates then need to be scaled to the *displayed* preview size.

//     return Stack(
//       children: _recognitions!.map((re) {
//         // Get bounding box coordinates normalized (0-1) relative to imageWidth/imageHeight passed to detectObjectOnFrame
//         double x = re['rect']['x'];
//         double y = re['rect']['y'];
//         double w = re['rect']['w'];
//         double h = re['rect']['h'];

//         // Calculate the bounding box position and size in screen coordinates
//         // Scale normalized coordinates (relative to _imageWidth, _imageHeight)
//         // to the pixel dimensions of the *displayed* preview (_previewSize).
//         // Then offset by the preview's position on the screen (_previewPosition).

//         double overlayLeft = _previewPosition!.dx + (x * _previewSize!.width);
//         double overlayTop = _previewPosition!.dy + (y * _previewSize!.height);
//         double overlayWidth = w * _previewSize!.width;
//         double overlayHeight = h * _previewSize!.height;

//         // Ensure the text label is readable and positioned reasonably
//         double textHeight = 12; // Approximate text height
//         // Position text either just above or just below the box
//         double textTop = overlayTop > textHeight + 5
//             ? overlayTop - textHeight - 5
//             : overlayTop + overlayHeight + 5;

//         // Clamp position to screen bounds if necessary (optional, but can prevent text overflow)
//         // Get screen dimensions for clamping
//         final screenWidth = MediaQuery.of(context).size.width;
//         final screenHeight = MediaQuery.of(context).size.height;

//         overlayLeft = overlayLeft.clamp(0.0, screenWidth - overlayWidth);
//         overlayTop = overlayTop.clamp(0.0, screenHeight - overlayHeight);
//         // Clamp textTop relative to screen height
//         textTop = textTop.clamp(0.0, screenHeight - textHeight);

//         return Positioned(
//           left: overlayLeft,
//           top: overlayTop,
//           width: overlayWidth,
//           height: overlayHeight,
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                   color: const Color.fromARGB(255, 182, 144, 141),
//                   width: 2), // Changed color slightly for visibility
//             ),
//             // Use Stack to position text within the bounding box container
//             child: Stack(
//               children: [
//                 Positioned(
//                   left: 4, // Small padding from left edge of box
//                   // Use the calculated textTop relative to the screen, then subtract overlayTop
//                   // to get position relative to the bounding box container's top edge.
//                   top: textTop - overlayTop,
//                   child: Text(
//                     // Display detected class and confidence
//                     "${re['detectedClass']} ${(re['confidenceInClass'] * 100).toStringAsFixed(0)}%",
//                     style: TextStyle(
//                       color: Colors.white, // Changed text color for visibility
//                       fontSize: 12,
//                       backgroundColor: Colors.red
//                           .withOpacity(0.8), // Semi-transparent background
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

// // Remember to add dependencies and assets in your pubspec.yaml:
// /*
// dependencies:
//   flutter:
//     sdk: flutter

//   camera: ^latest_version # Use a compatible version
//   tflite_v2: ^latest_version # Use tflite_v2 as requested

// dev_dependencies:
//   flutter_test:
//     sdk: flutter

//   flutter_lints: ^latest_version

// flutter:
//   uses-material-design: true

//   assets:
//     # Add your models directory here
//     - assets/models/

// */
// // Also ensure you have camera permissions configured for Android and iOS.