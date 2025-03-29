import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''
{
  "disease": "Cherry Powdery Mildew",
  "image": "assets/images/cherry_powdery.jpg",
  "symptoms": "Cherry powdery mildew manifests as white to grayish, powdery patches on the leaves, stems, and occasionally fruits. These patches consist of fungal mycelium and spores. Young leaves are particularly susceptible, and severe infections can cause leaf distortion, curling, and premature drop. On fruits, the mildew can lead to russeting and cracking, reducing their marketability. The white patches can spread rapidly under favorable conditions, covering large portions of the plant. In severe cases, it can inhibit photosynthesis and overall plant growth.",
  "favorable_environment": "Cherry powdery mildew thrives in warm, dry conditions, particularly when nights are cool and days are warm. High humidity and poor air circulation exacerbate the disease. Overcrowding of plants and excessive nitrogen fertilization can also create a favorable environment for the fungus. The fungus overwinters in dormant buds and on fallen debris, releasing spores in the spring to initiate new infections. Certain cherry varieties are more susceptible than others, and the disease tends to be more severe in regions with mild winters and dry summers.",
  "management": "1. Choose resistant cherry varieties whenever possible.\\n2.Ensure proper spacing between plants to improve air circulation.\\n3. Prune trees to remove infected branches and open up the canopy.\\n4. Rake and remove fallen leaves and debris to eliminate overwintering sites for the fungus.\\n5. Apply fungicides labeled for powdery mildew control at the first signs of infection.\\n6. Use sulfur-based fungicides or horticultural oils as preventive measures.\\n7. Avoid excessive nitrogen fertilization, which promotes lush growth susceptible to infection.\\n8. Monitor plants regularly for early symptoms and take prompt action.\\n9. Provide adequate irrigation to maintain plant health, but avoid overhead watering, which can increase humidity.\\n10. Consider using biological control agents, such as beneficial fungi, to suppress powdery mildew."
}
''';

class CherryDiseaseDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final jsonData = json.decode(DiseaseData);

    return Scaffold(
      appBar: AppBar(
        title: Text(jsonData['disease']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(jsonData['image']),
            SizedBox(height: 16.0),
            Text(
              'Symptoms',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(jsonData['symptoms']),
            SizedBox(height: 16.0),
            Text(
              'Favorable Environment',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(jsonData['favorable_environment']),
            SizedBox(height: 16.0),
            Text(
              'Management',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(jsonData['management'].replaceAll('\\n', '\n')),
          ],
        ),
      ),
    );
  }
}
