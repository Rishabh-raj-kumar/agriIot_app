import 'dart:io';

import 'package:agriculture/Disease/CornCommonRust.dart';
import 'package:agriculture/Disease/CornGrayLeaf.dart';
import 'package:agriculture/Disease/GrapeLeafBlight.dart';
import 'package:agriculture/Disease/PotatoEarlyBlight.dart';
import 'package:agriculture/Disease/TomatoEarlyBlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

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
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

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
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    var imageMap = File(image.path);

    setState(() {
      filePath = imageMap;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

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
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plant Diease Detection"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 18,
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
                height: 8,
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
