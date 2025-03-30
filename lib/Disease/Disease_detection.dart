import 'dart:convert';
import 'dart:io';
import 'package:agriculture/Disease/CornCommonRust.dart';
import 'package:agriculture/Disease/CornGrayLeaf.dart';
import 'package:agriculture/Disease/GrapeLeafBlight.dart';
import 'package:agriculture/Disease/PotatoEarlyBlight.dart';
import 'package:agriculture/Disease/TomatoEarlyBlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'AppleScab.dart';

const String agricultureSchemesJson = '''
[
  {
    "schemeName": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
    "description": "Provides income support to all landholding farmer families across the country, with cultivable landholding, subject to certain exclusions.",
    "benefits": "Rs. 6000 per year, in three equal installments, directly into the farmers' bank accounts.",
    "eligibility": "All landholding farmer families with cultivable land, subject to exclusions like income tax payers and institutional landholders.",
    "website": "https://pmkisan.gov.in/"
  },
  {
    "schemeName": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
    "description": "Provides comprehensive risk insurance coverage to farmers for losses suffered due to natural calamities.",
    "benefits": "Insurance coverage for crop loss due to non-preventable natural risks.",
    "eligibility": "All farmers growing notified crops in notified areas.",
    "website": "https://pmfby.gov.in/"
  },
  {
    "schemeName": "Soil Health Card Scheme",
    "description": "Provides soil health cards to farmers, containing information about soil nutrient status and recommendations for appropriate fertilizer use.",
    "benefits": "Improved soil health, reduced input costs, and increased crop productivity.",
    "eligibility": "All farmers owning agricultural land.",
    "website": "https://soilhealth.dac.gov.in/"
  },
  {
    "schemeName": "Paramparagat Krishi Vikas Yojana (PKVY)",
    "description": "Promotes organic farming through cluster formation and capacity building of farmers.",
    "benefits": "Financial assistance for organic farming, improved soil health, and access to organic markets.",
    "eligibility": "Groups of farmers adopting organic farming practices.",
    "website": "https://pgsindia-ncof.gov.in/"
  },
  {
    "schemeName": "Kisan Credit Card (KCC)",
    "description": "Provides farmers with easy access to credit for agricultural inputs and other needs.",
    "benefits": "Credit at concessional interest rates, flexible repayment options.",
    "eligibility": "Farmers engaged in agriculture and allied activities.",
    "website": "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
  },
  {
    "schemeName": "National Agriculture Market (eNAM)",
    "description": "A pan-India electronic trading portal that networks the existing Agricultural Produce Market Committees (APMCs) to create a unified national market for agricultural commodities.",
    "benefits": "Better price discovery, transparent auction process, and reduced transaction costs.",
    "eligibility": "Farmers and traders registered with eNAM.",
    "website": "https://enam.gov.in/web/"
  },
  {
    "schemeName": "Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)",
    "description": "Aims to enhance physical access of water on farm and expand cultivable area under assured irrigation, improve on farm water use efficiency, introduce sustainable water conservation practices etc.",
    "benefits": "Improved irrigation facilities, water conservation, and enhanced crop productivity.",
    "eligibility": "All farmers with agricultural land.",
    "website": "https://pmksy.gov.in/"
  },
  {
    "schemeName": "Mission for Integrated Development of Horticulture (MIDH)",
    "description": "Aims to promote holistic growth of the horticulture sector, including fruits, vegetables, root and tuber crops, mushrooms, spices, flowers, aromatic plants, coconut, cashew, bamboo and honey.",
    "benefits": "Financial assistance for horticulture development, improved productivity, and market access.",
    "eligibility": "Farmers and entrepreneurs engaged in horticulture.",
    "website": "https://midh.gov.in/"
  },
  {
    "schemeName": "Rashtriya Krishi Vikas Yojana (RKVY)",
    "description": "Aims to achieve 4% annual growth in the agriculture sector by ensuring holistic development of agriculture and allied sectors.",
    "benefits": "Financial assistance for agricultural development projects and infrastructure.",
    "eligibility": "State governments and agricultural institutions.",
    "website": "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
  },
  {
    "schemeName": "National Food Security Mission (NFSM)",
    "description": "Aims to increase production of rice, wheat, pulses, coarse cereals and nutri-cereals through area expansion and productivity enhancement.",
    "benefits": "Increased food production and availability, improved farmer income.",
    "eligibility": "All farmers engaged in the production of notified crops.",
    "website": "https://nfsm.gov.in/"
  }
]
''';

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

  List<dynamic> schemes = [];
  Future<void> _loadSchemes() async {
    setState(() {
      schemes = json.decode(agricultureSchemesJson);
    });
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
    _loadSchemes();
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
                  height: 220,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 200,
                          width: 200,
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
              Divider(),
              SizedBox(height: 10),
              if (schemes.isNotEmpty)
                Column(
                  children: [
                    const Text("Agriculture Schemes",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: schemes.length,
                      itemBuilder: (context, index) {
                        final scheme = schemes[index];
                        return Card(
                          elevation: 8,
                          margin: const EdgeInsets.all(8),
                          shadowColor: Colors.greenAccent,
                          color: Colors.greenAccent.withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: ListTile(
                            title: Text(
                              scheme['schemeName'],
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 23, 106, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(scheme['description']),
                                const SizedBox(height: 8),
                                Text('Benefits: ${scheme['benefits']}'),
                                const SizedBox(height: 8),
                                Text('Eligibility: ${scheme['eligibility']}'),
                                const SizedBox(height: 8),
                                Text('Website: ${scheme['website']}'),
                              ],
                            ),
                            onTap: () async {
                              // Add onTap
                              final url = scheme['website'];
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Could not launch $url')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
