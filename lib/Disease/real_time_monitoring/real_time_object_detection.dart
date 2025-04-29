// import 'dart:async';
// import 'dart:isolate'; // Needed for compute function (image conversion)

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart'; // for compute
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:permission_handler/permission_handler.dart';

// import 'box_widget.dart';
// // import 'models.dart';
// import 'object_detection_servicr.dart';

// class RealTimeObjectDetection extends StatefulWidget {
//   const RealTimeObjectDetection({super.key});

//   @override
//   State<RealTimeObjectDetection> createState() =>
//       _RealTimeObjectDetectionState();
// }

// class _RealTimeObjectDetectionState extends State<RealTimeObjectDetection>
//     with WidgetsBindingObserver {
//   CameraController? _cameraController;
//   List<CameraDescription>? _cameras;
//   late ObjectDetectionService _objectDetectionService;
//   List<DetectionResult> _detectionResults = [];
//   bool _isDetecting = false; // Flag to prevent concurrent detections
//   bool _isCameraInitialized = false;
//   bool _isProcessingFrame =
//       false; // Flag for image conversion/processing isolate

//   // To store the size of the preview widget
//   Size? _previewSize;
//   // To store the actual resolution of the camera image
//   Size _imageSize = Size.zero;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _objectDetectionService =
//         ObjectDetectionService(); // Initializes model loading async
//     _requestPermissionsAndInitializeCamera();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopCameraStream();
//     _cameraController?.dispose();
//     _objectDetectionService.dispose(); // Important: Close the interpreter
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     final CameraController? cameraController = _cameraController;

//     // App state changed before we got the chance to initialize.
//     if (cameraController == null || !cameraController.value.isInitialized) {
//       return;
//     }

//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.paused) {
//       // Stop camera stream and dispose controller when inactive or paused
//       _stopCameraStream();
//       cameraController.dispose(); // Dispose controller when paused
//       if (mounted) {
//         setState(() {
//           _isCameraInitialized = false;
//         });
//       }
//     } else if (state == AppLifecycleState.resumed) {
//       // Re-initialize camera when resuming
//       _requestPermissionsAndInitializeCamera();
//     }
//     // `detached` can be handled if needed, but dispose already covers it.
//   }

//   Future<void> _requestPermissionsAndInitializeCamera() async {
//     // 1. Request Camera Permission
//     var status = await Permission.camera.request();
//     if (status.isGranted) {
//       // 2. Initialize Camera
//       await _initializeCamera();
//     } else {
//       print("Camera permission denied");
//       // Optionally show a message to the user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content:
//                 Text("Camera permission is required to use this feature.")));
//       }
//     }
//   }

//   Future<void> _initializeCamera() async {
//     try {
//       _cameras = await availableCameras();
//       if (_cameras == null || _cameras!.isEmpty) {
//         print("No cameras available");
//         return;
//       }

//       // Use the first available camera (usually back camera)
//       _cameraController = CameraController(
//         _cameras![0], // Or choose a specific camera
//         ResolutionPreset.high, // Choose an appropriate resolution
//         enableAudio: false, // We don't need audio
//         imageFormatGroup:
//             ImageFormatGroup.bgra8888, // Or yuv420 for Android potentially
//       );

//       await _cameraController!.initialize();

//       // Get the actual image size after initialization
//       if (_cameraController!.value.previewSize != null) {
//         _imageSize = Size(
//             _cameraController!.value.previewSize!
//                 .height, // Width and height are swapped in previewSize
//             _cameraController!.value.previewSize!.width);
//         print("Camera Initialized. Image size: $_imageSize");
//       }

//       if (!mounted) return; // Check if widget is still mounted

//       setState(() {
//         _isCameraInitialized = true;
//       });

//       // Start the image stream for detection
//       await _startCameraStream();
//     } on CameraException catch (e) {
//       print("Error initializing camera: ${e.code}\n${e.description}");
//       // Handle specific errors (e.g., CameraAccessDenied)
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text("Error initializing camera: ${e.description}")));
//       }
//       setState(() {
//         _isCameraInitialized = false;
//       });
//     } catch (e) {
//       print("Unexpected error initializing camera: $e");
//       setState(() {
//         _isCameraInitialized = false;
//       });
//     }
//   }

//   Future<void> _startCameraStream() async {
//     if (_cameraController == null ||
//         !_cameraController!.value.isInitialized ||
//         _cameraController!.value.isStreamingImages) {
//       print("Camera not ready or already streaming.");
//       return;
//     }
//     // Ensure model is loaded before starting stream
//     if (!_objectDetectionService.isLoaded) {
//       print("Model not loaded yet, waiting...");
//       // Optionally show a loading indicator
//       await Future.delayed(const Duration(seconds: 1)); // Wait a bit longer
//       if (!_objectDetectionService.isLoaded) {
//         print("Model still not loaded. Aborting stream start.");
//         return; // Don't start stream if model failed to load
//       }
//     }

//     print("Starting camera stream...");
//     try {
//       // Set state *before* starting the stream to avoid race conditions with detection loop
//       _isDetecting = false; // Reset detection flag

//       await _cameraController!
//           .startImageStream((CameraImage cameraImage) async {
//         if (_isDetecting || _isProcessingFrame) {
//           // Skip frame if detection or processing is already in progress
//           return;
//         }

//         // Ensure model is ready before processing
//         if (!_objectDetectionService.isLoaded) return;

//         if (mounted) {
//           setState(() {
//             _isDetecting = true; // Mark as detecting
//           });
//         }

//         // Update image size if it hasn't been set yet (sometimes needs a frame)
//         if (_imageSize == Size.zero) {
//           _imageSize =
//               Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
//           print("Image size updated from frame: $_imageSize");
//         }

//         // Perform image conversion and detection
//         try {
//           // Process frame in background using compute for heavy tasks
//           _isProcessingFrame = true; // Mark processing start
//           List<DetectionResult> results = await compute(_processCameraImage, {
//             'cameraImage': cameraImage,
//             'objectDetectionService':
//                 _objectDetectionService, // Pass service instance
//           });
//           _isProcessingFrame = false; // Mark processing end

//           // Update UI only if widget is still mounted
//           if (mounted) {
//             setState(() {
//               _detectionResults = results;
//             });
//           }
//         } catch (e) {
//           print("Error processing frame: $e");
//           _isProcessingFrame = false; // Ensure flag is reset on error
//         } finally {
//           if (mounted) {
//             // Allow next frame detection AFTER processing completes or fails
//             setState(() {
//               _isDetecting = false;
//             });
//           }
//         }
//       });
//     } on CameraException catch (e) {
//       print("Error starting image stream: ${e.code}\n${e.description}");
//     } catch (e) {
//       print("Unexpected error starting image stream: $e");
//     }
//   }

//   Future<void> _stopCameraStream() async {
//     if (_cameraController != null &&
//         _cameraController!.value.isStreamingImages) {
//       try {
//         await _cameraController!.stopImageStream();
//         print("Camera stream stopped.");
//       } on CameraException catch (e) {
//         print("Error stopping image stream: ${e.code}\n${e.description}");
//       } catch (e) {
//         print("Unexpected error stopping image stream: $e");
//       }
//     }
//     if (mounted) {
//       setState(() {
//         _isDetecting = false; // Reset flag when stopping
//         _isProcessingFrame = false;
//       });
//     }
//   }

//   // --- Build Method ---
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Real-time Detection')),
//       body: LayoutBuilder(
//         // Use LayoutBuilder to get the constraints of the body
//         builder: (context, constraints) {
//           final bodySize = Size(constraints.maxWidth, constraints.maxHeight);

//           // Calculate the size and offset of the camera preview
//           Size calculatedPreviewSize = Size.zero;
//           Offset previewOffset = Offset.zero;
//           double cameraAspectRatio = 1.0; // Default

//           // Ensure camera controller is initialized and has preview size information
//           if (_isCameraInitialized &&
//               _cameraController != null &&
//               _cameraController!.value.previewSize != null) {
//             // Use the aspect ratio from the camera image stream size (_imageSize)
//             // which is more reliable for bounding box scaling than previewSize
//             if (_imageSize != Size.zero) {
//               cameraAspectRatio = _imageSize.width / _imageSize.height;
//             } else {
//               // Fallback: Use the aspect ratio from the controller's previewSize
//               // Note: controller.value.previewSize might have width/height swapped
//               // depending on device orientation and camera sensor orientation.
//               // It's generally safer to rely on _imageSize from the image stream.
//               // We use value.aspectRatio here which is usually correct.
//               cameraAspectRatio = _cameraController!.value.aspectRatio;
//             }

//             final bodyAspectRatio = bodySize.width / bodySize.height;

//             if (bodyAspectRatio > cameraAspectRatio) {
//               // Body is wider than camera aspect ratio, camera fills height
//               calculatedPreviewSize =
//                   Size(bodySize.height * cameraAspectRatio, bodySize.height);
//               previewOffset = Offset(
//                   (bodySize.width - calculatedPreviewSize.width) / 2,
//                   0); // Centered horizontally
//             } else {
//               // Body is taller than or equal to camera aspect ratio, camera fills width
//               calculatedPreviewSize =
//                   Size(bodySize.width, bodySize.width / cameraAspectRatio);
//               previewOffset = Offset(
//                   0,
//                   (bodySize.height - calculatedPreviewSize.height) /
//                       2); // Centered vertically
//             }

//             // Update the instance variable for use by the painter.
//             // This build method will use this updated value in the same frame.
//             _previewSize = calculatedPreviewSize;
//           } else {
//             // If camera is not initialized, reset preview size
//             _previewSize = null;
//           }

//           return Stack(
//             children: [
//               // Camera Preview - Positioned to fill the calculated area
//               if (_isCameraInitialized &&
//                   _cameraController != null &&
//                   _previewSize != null)
//                 Positioned(
//                   left: previewOffset.dx,
//                   top: previewOffset.dy,
//                   width: _previewSize!.width,
//                   height: _previewSize!.height,
//                   // The CameraPreview widget itself will handle displaying the feed
//                   // within this sized box, likely using a BoxFit.cover-like behavior implicitly.
//                   child: CameraPreview(_cameraController!),
//                 ),

//               // Bounding Boxes Overlay using CustomPaint
//               // Only show if camera is initialized, results exist, preview size is calculated,
//               // and original image size is known for scaling.
//               if (_isCameraInitialized &&
//                   _detectionResults.isNotEmpty &&
//                   _previewSize != null &&
//                   _imageSize != Size.zero)
//                 Positioned(
//                   left: previewOffset.dx,
//                   top: previewOffset.dy,
//                   width: _previewSize!.width,
//                   height: _previewSize!.height,
//                   child: CustomPaint(
//                     painter: BBoxPainter(
//                       results: _detectionResults,
//                       previewSize:
//                           _previewSize!, // Pass the calculated preview size
//                       originalImageSize:
//                           _imageSize, // Pass the actual camera image size
//                     ),
//                     size:
//                         _previewSize!, // The size of the area the painter draws on
//                   ),
//                 ),

//               // Loading Indicator - Keep centered in the Stack
//               if (!_isCameraInitialized || !_objectDetectionService.isLoaded)
//                 const Center(child: CircularProgressIndicator()),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCameraPreview() {
//     if (!_isCameraInitialized || _cameraController == null) {
//       return const Center(child: Text("Initializing Camera..."));
//     }

//     // Use AspectRatio to maintain the camera's aspect ratio
//     // Important for correct bounding box alignment
//     final camera = _cameraController!;
//     return AspectRatio(
//       aspectRatio: camera.value.aspectRatio, // Use controller's aspect ratio
//       child: CameraPreview(camera),
//     );
//   }
// }

// // --- Background Isolate Function ---
// // This function runs in a separate isolate to avoid blocking the UI thread.
// // IMPORTANT: It needs access to the ObjectDetectionService instance or a way to load it independently.
// // Passing the instance works for simple cases, but be mindful of isolate memory boundaries.
// Future<List<DetectionResult>> _processCameraImage(
//     Map<String, dynamic> args) async {
//   final CameraImage cameraImage = args['cameraImage'];
//   final ObjectDetectionService objectDetectionService =
//       args['objectDetectionService'];

//   // 1. Convert CameraImage to img.Image (this is often the bottleneck)
//   img.Image? image = _convertCameraImage(cameraImage);

//   if (image == null) {
//     print("Image conversion failed.");
//     return [];
//   }

//   // 2. Run detection using the provided service instance
//   List<DetectionResult> results =
//       await objectDetectionService.detectObjects(image);
//   return results;
// }

// // Helper function to convert CameraImage to img.Image
// // Note: This conversion can be slow. Consider platform-specific native code
// // or optimized libraries if performance is critical.
// // This example assumes BGRA8888 format. Adjust if using YUV420.
// img.Image? _convertCameraImage(CameraImage image) {
//   try {
//     switch (image.format.group) {
//       case ImageFormatGroup.bgra8888:
//         return img.Image.fromBytes(
//           image.width,
//           image.height,
//           image.planes[0].bytes.buffer
//               .asUint8List(), // Get buffer for direct access
//           format: img.Format.bgra, // Specify byte order
//         );

//       case ImageFormatGroup.yuv420:
//         // YUV conversion is more complex and platform-dependent
//         // Requires a dedicated YUV -> RGB conversion function
//         print("YUV420 conversion not implemented in this example.");
//         return null; // Placeholder - requires implementation

//       default:
//         print("Unsupported image format: ${image.format.group}");
//         return null;
//     }
//   } catch (e) {
//     print("Error converting CameraImage: $e");
//     return null;
//   }
// }
