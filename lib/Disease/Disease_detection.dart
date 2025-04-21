import 'dart:convert';
import 'dart:io';
import 'package:agriculture/Disease/CornCommonRust.dart';
import 'package:agriculture/Disease/CornGrayLeaf.dart';
import 'package:agriculture/Disease/GrapeLeafBlight.dart';
import 'package:agriculture/Disease/PotatoEarlyBlight.dart';
import 'package:agriculture/Disease/TomatoEarlyBlight.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'AppleScab.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  _DiseaseDetectionPageState createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  Future<void> _tfLteInit() async {
    String? res = await Tflite.loadModel(
        model: "assets/models/model_unquant.tflite",
        labels: "assets/models/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);

    if (recognitions == null) {
      print("recognitions is Null");
      return;
    }
    print(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });

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
  }

  pickImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);

    if (recognitions == null) {
      print("recognitions is Null");
      return;
    }
    print(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });

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
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Diease Detection"),
      ),
      body: Container(
        color: Colors.blue.shade100,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(color: Colors.blue, boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ]),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/uploads.jpg'),
                            ),
                          ),
                          child: filePath == null
                              ? const Text('')
                              : Image.file(
                                  filePath!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageCamera();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Take a Photo",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Pick from gallery",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
