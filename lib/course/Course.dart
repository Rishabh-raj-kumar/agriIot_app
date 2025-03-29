import 'dart:convert';
import 'package:agriculture/Multilanguage/Applocal.dart';
import 'package:flutter/material.dart';
import 'crops_data.dart';
import 'plant_disease.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  late List<dynamic> crops;
  late List<dynamic> diseases;
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
    crops = json.decode(cropsDataJson)['crops'];
    diseases = json.decode(plantDiseasesDataJson)['diseases'];
    _initLocalization();
  }

  Future<void> _initLocalization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      localizations = AppLocalizations(Locale(languageCode));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localizations == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.learn ?? 'Learn'), // Null-aware operator
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(localizations?.home ?? 'Home', // Null-aware operator
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                return _buildGridItem(crop, true);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  localizations?.disease ?? 'Disease', // Null-aware operator
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: diseases.length,
              itemBuilder: (context, index) {
                final disease = diseases[index];
                return _buildGridItem(disease, false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(dynamic item, bool isCrop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showDetailsDialog(context, item, isCrop);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  item['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item['name'][localizations?.locale.languageCode ??
                        'en'], // Null-aware
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isCrop)
                    Text(
                      item['season'][localizations?.locale.languageCode ??
                          'en'], // Null-aware
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, dynamic item, bool isCrop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item['name']
              [localizations?.locale.languageCode ?? 'en']), // Null-aware
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(item['image'], fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text(
                  isCrop
                      ? localizations?.cropDetails ?? "Crop Details"
                      : localizations?.disease ?? "Disease", // Null-aware
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isCrop
                      ? item['details'][localizations?.locale.languageCode ??
                          'en'] // Null-aware
                      : item['description'][
                          localizations?.locale.languageCode ??
                              'en'], // Null-aware
                ),
                const SizedBox(height: 10),
                Text(
                  isCrop
                      ? localizations?.weather ?? "Weather"
                      : localizations?.tipsForFarmers ??
                          "Tips for Farmers", // Null-aware
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isCrop
                      ? item['season'][localizations?.locale.languageCode ??
                          'en'] // Null-aware
                      : item['cure'][localizations?.locale.languageCode ??
                          'en'], // Null-aware
                ),
                const SizedBox(height: 10),
                if (isCrop)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations?.tipsForFarmers ??
                            "Tips for Farmers", // Null-aware
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(item['requirements'][
                          localizations?.locale.languageCode ??
                              'en']), // Null-aware
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
