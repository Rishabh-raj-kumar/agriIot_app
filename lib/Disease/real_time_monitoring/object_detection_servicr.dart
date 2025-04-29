// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;
// import 'package:tflite_flutter/tflite_flutter.dart';

// import 'models.dart'; // Import the DetectionResult class

// class ObjectDetectionService {
//   Interpreter? _interpreter;
//   List<String>? _labels;
//   bool _isModelLoaded = false;

//   // --- Model Configuration ---
//   static const String _modelPath =
//       'assets/models/realtime_disease.tflite'; // Your model
//   static const String _labelPath = 'assets/models/classes.txt'; // Your labels
//   static const int inputWidth = 640; // Must match imgsz used during export
//   static const int inputHeight = 640; // Must match imgsz used during export
//   static const int numClasses = 27; // Classes your model was trained on
//   // --- --- --- --- --- --- ---

//   ObjectDetectionService() {
//     loadModel();
//   }

//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset(_modelPath);
//       _interpreter!.allocateTensors(); // Allocate tensors AFTER loading
//       await _loadLabels();
//       _isModelLoaded = true;
//       print('ObjectDetectionService: Model and labels loaded successfully.');

//       // Print model input/output details (optional but helpful)
//       var inputDetails = _interpreter!.getInputTensor(0);
//       var outputDetails = _interpreter!.getOutputTensor(0);
//       print(
//           "Input details: ${inputDetails.shape} ${inputDetails.type}"); // e.g., [1, 640, 640, 3] TfLiteType.float32
//       print(
//           "Output details: ${outputDetails.shape} ${outputDetails.type}"); // Should be [1, 31, 8400] TfLiteType.float32

//       // Verify output shape matches expectations
//       if (outputDetails.shape.length != 3 ||
//           outputDetails.shape[0] != 1 ||
//           outputDetails.shape[1] != (4 + numClasses) || // 4 bbox + num classes
//           outputDetails.shape[2] <= 0) {
//         // number of detections > 0
//         print(
//             "Error: Model output shape ${outputDetails.shape} is not the expected [1, ${4 + numClasses}, N]");
//         _isModelLoaded = false; // Mark as not loaded if shape mismatch
//       }
//     } catch (e) {
//       print('Error loading model or labels: $e');
//       _isModelLoaded = false;
//     }
//   }

//   Future<void> _loadLabels() async {
//     try {
//       final labelsData = await rootBundle.loadString(_labelPath);
//       _labels =
//           labelsData.split('\n').where((label) => label.isNotEmpty).toList();
//       if (_labels!.length != numClasses) {
//         print(
//             "Warning: Number of labels (${_labels!.length}) does not match numClasses ($numClasses)");
//       }
//       print('Labels loaded: ${_labels?.length ?? 0}');
//     } catch (e) {
//       print('Error loading labels: $e');
//       _labels = []; // Ensure labels list is not null
//     }
//   }

//   /// Preprocesses the input image.
//   /// Resizes, normalizes, and converts to Float32List.
//   Float32List _preprocessImage(img.Image image) {
//     // 1. Resize
//     img.Image resizedImage = img.copyResize(
//       image,
//       width: inputWidth,
//       height: inputHeight,
//     );

//     // 2. Normalize and convert to Float32List (input shape [1, H, W, 3])
//     var inputBytes = Float32List(1 * inputWidth * inputHeight * 3);
//     int pixelIndex = 0;
//     for (int y = 0; y < inputHeight; y++) {
//       for (int x = 0; x < inputWidth; x++) {
//         var pixel = resizedImage.getPixel(x, y);
//         var r = img.getRed(pixel);
//         var g = img.getGreen(pixel);
//         var b = img.getBlue(pixel);
//         inputBytes[pixelIndex++] = r / 255.0; // Normalize to [0.0, 1.0]
//         inputBytes[pixelIndex++] = g / 255.0;
//         inputBytes[pixelIndex++] = b / 255.0;
//       }
//     }
//     return inputBytes;
//   }

//   /// Runs inference and returns detected objects.
//   Future<List<DetectionResult>> detectObjects(img.Image image) async {
//     if (!_isModelLoaded || _interpreter == null || _labels == null) {
//       print('Model not loaded or interpreter/labels null.');
//       return [];
//     }

//     final int originalImageWidth = image.width;
//     final int originalImageHeight = image.height;

//     // 1. Preprocess the input image
//     final inputTensor = _preprocessImage(image);

//     // 2. Define the output buffer with the correct shape [1, 31, 8400]
//     // Note: The actual shape from getOutputTensor might be slightly different
//     // if the model export changed defaults, but this is standard.
//     var outputShape =
//         _interpreter!.getOutputTensor(0).shape; // Should be [1, 31, 8400]
//     // Ensure we use the actual output shape for buffer allocation
//     int numDetectionsOutput = outputShape[2]; // 8400
//     int numFeaturesOutput = outputShape[1]; // 31
//     var outputBuffer =
//         List.filled(1 * numFeaturesOutput * numDetectionsOutput, 0.0)
//             .reshape([1, numFeaturesOutput, numDetectionsOutput]);

//     // 3. Run inference
//     try {
//       _interpreter!.run(inputTensor.buffer.asUint8List(), outputBuffer);
//     } catch (e) {
//       print("Error running inference: $e");
//       return [];
//     }

//     // 4. Post-process the output
//     // Pass the actual output list [31, 8400] and original image size
//     List<DetectionResult> results = _postProcessOutput(
//         outputBuffer[0], // Shape [31, 8400]
//         originalImageWidth,
//         originalImageHeight);

//     return results;
//   }

//   /// Post-processes the raw model output.
//   List<DetectionResult> _postProcessOutput(List<List<double>> output,
//       int originalImageWidth, int originalImageHeight) {
//     // output shape is [31, 8400]
//     // 31 = 4 (bbox: cx, cy, w, h) + num_classes (27)
//     // 8400 = number of detection candidates

//     const double confidenceThreshold = 0.5; // Filter threshold
//     const double iouThresholdNMS = 0.45; // NMS IoU threshold

//     List<Rect> boxes = [];
//     List<double> scores = [];
//     List<int> classIndices = [];

//     int numDetections = output[0].length; // 8400

//     for (int i = 0; i < numDetections; i++) {
//       // Find the class with the highest score for this detection candidate
//       double maxScore = 0.0;
//       int maxClassIndex = -1;
//       for (int j = 0; j < numClasses; j++) {
//         double score = output[4 + j][i]; // Scores start after the 4 bbox coords
//         if (score > maxScore) {
//           maxScore = score;
//           maxClassIndex = j;
//         }
//       }

//       // Filter based on confidence threshold
//       if (maxScore > confidenceThreshold) {
//         // Extract bounding box coordinates (center x, center y, width, height)
//         // These are normalized relative to the input size (e.g., 640x640)
//         double cx = output[0][i];
//         double cy = output[1][i];
//         double w = output[2][i];
//         double h = output[3][i];

//         // Convert center coords to top-left (still normalized)
//         double x1 = cx - w / 2.0;
//         double y1 = cy - h / 2.0;
//         double x2 = cx + w / 2.0;
//         double y2 = cy + h / 2.0;

//         // Scale coordinates back to original image size and clamp
//         boxes.add(Rect.fromLTRB(
//           (x1 * originalImageWidth).clamp(0, originalImageWidth).toDouble(),
//           (y1 * originalImageHeight).clamp(0, originalImageHeight).toDouble(),
//           (x2 * originalImageWidth).clamp(0, originalImageWidth).toDouble(),
//           (y2 * originalImageHeight).clamp(0, originalImageHeight).toDouble(),
//         ));
//         scores.add(maxScore);
//         classIndices.add(maxClassIndex);
//       }
//     }

//     // Perform Non-Max Suppression (NMS)
//     List<int> nmsResultIndices =
//         nonMaxSuppression(boxes, scores, iouThreshold: iouThresholdNMS);

//     // Build the final list of results using NMS indices
//     List<DetectionResult> finalResults = [];
//     for (int index in nmsResultIndices) {
//       if (_labels != null &&
//           classIndices[index] >= 0 &&
//           classIndices[index] < _labels!.length) {
//         finalResults.add(DetectionResult(
//           boxes[index],
//           _labels![classIndices[index]], // Get class name
//           scores[index],
//         ));
//       } else {
//         print(
//             "Warning: Invalid class index ($classIndices[index]) or labels not loaded.");
//       }
//     }
//     // print("Detected: ${finalResults.length} objects after NMS");
//     return finalResults;
//   }

//   // --- Non-Max Suppression (NMS) ---
//   // (Using the simple implementation provided previously)
//   List<int> nonMaxSuppression(List<Rect> boxes, List<double> scores,
//       {double iouThreshold = 0.5}) {
//     if (boxes.isEmpty) return [];

//     List<int> indices = List<int>.generate(boxes.length, (i) => i);
//     // Sort by score descending. Important!
//     indices.sort((a, b) => scores[b].compareTo(scores[a]));

//     List<int> picked = [];
//     List<bool> suppressed = List<bool>.filled(boxes.length, false);

//     for (int i = 0; i < indices.length; i++) {
//       int currentIdx = indices[i];
//       if (suppressed[currentIdx]) continue;

//       picked.add(currentIdx);
//       suppressed[currentIdx] = true; // Mark the current box as picked

//       Rect boxA = boxes[currentIdx];

//       for (int j = i + 1; j < indices.length; j++) {
//         int compareIdx = indices[j];
//         if (suppressed[compareIdx]) continue;

//         Rect boxB = boxes[compareIdx];
//         double iou = calculateIoU(boxA, boxB);

//         if (iou > iouThreshold) {
//           suppressed[compareIdx] = true; // Suppress boxes with high IoU
//         }
//       }
//     }
//     return picked;
//   }

//   // Helper function to calculate Intersection over Union (IoU)
//   double calculateIoU(Rect rect1, Rect rect2) {
//     double intersectionLeft = rect1.left > rect2.left ? rect1.left : rect2.left;
//     double intersectionTop = rect1.top > rect2.top ? rect1.top : rect2.top;
//     double intersectionRight =
//         rect1.right < rect2.right ? rect1.right : rect2.right;
//     double intersectionBottom =
//         rect1.bottom < rect2.bottom ? rect1.bottom : rect2.bottom;

//     if (intersectionRight <= intersectionLeft ||
//         intersectionBottom <= intersectionTop) {
//       return 0.0; // No overlap
//     }

//     double intersectionArea = (intersectionRight - intersectionLeft) *
//         (intersectionBottom - intersectionTop);
//     double area1 = (rect1.right - rect1.left) * (rect1.bottom - rect1.top);
//     double area2 = (rect2.right - rect2.left) * (rect2.bottom - rect2.top);
//     double unionArea = area1 + area2 - intersectionArea;

//     if (unionArea <= 0) return 0.0;

//     double iou = intersectionArea / unionArea;
//     return iou.clamp(0.0, 1.0);
//   }
//   // --- End NMS ---

//   /// Disposes of the TFLite interpreter. Call when finished.
//   void dispose() {
//     _interpreter?.close();
//     _interpreter = null;
//     _isModelLoaded = false;
//     print("ObjectDetectionService disposed.");
//   }

//   /// Check if the model is loaded and ready.
//   bool get isLoaded => _isModelLoaded;
// }
