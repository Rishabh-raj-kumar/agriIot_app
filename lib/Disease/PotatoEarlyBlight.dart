import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''
{
  "disease": "Potato Early Blight",
  "image": "assets/images/blight-potato-plant.jpg",
  "symptoms": "Potato early blight initially appears as small, dark brown to black spots on the lower leaves. These spots enlarge rapidly, forming circular to oval lesions with concentric rings, giving them a target-like appearance. A yellow halo often surrounds the lesions. On stems, dark, sunken lesions can develop. Severe infections can lead to premature defoliation, reducing tuber yield and quality. Tubers may also develop sunken, dark lesions on their surface. Older leaves are more susceptible to infection. The disease progresses rapidly under warm, humid conditions.",
  "favorable_environment": "Potato early blight is caused by the fungus *Alternaria solani*. It thrives in warm, humid conditions, particularly during periods of frequent rainfall or heavy dew. The fungus overwinters in infected potato debris and soil, releasing spores in the spring to infect new plants. Stressed plants, such as those lacking adequate nutrients or water, are more susceptible to infection. Continuous potato cropping and susceptible potato varieties also contribute to disease development. The disease is more prevalent in regions with warm, wet summers.",
  "management": "1. Choose potato varieties with resistance to early blight.\\n2. Practice crop rotation with non-host crops to reduce inoculum levels.\\n3. Remove and destroy infected potato debris to minimize overwintering sites for the fungus.\\n4. Apply fungicides labeled for early blight control preventatively or at the first signs of infection.\\n5. Use protectant fungicides, such as chlorothalonil or mancozeb, before infection periods.\\n6. Apply systemic fungicides, such as difenoconazole or azoxystrobin, after infection has occurred.\\n7. Ensure proper plant spacing to improve air circulation and reduce humidity.\\n8. Provide adequate irrigation to maintain plant health, but avoid overhead watering, which can increase humidity.\\n9. Practice good weed control to minimize competition and improve air circulation.\\n10. Monitor fields regularly for early symptoms, especially during periods of high risk."
}
''';

class PotatoDiseaseDetail extends StatelessWidget {
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
