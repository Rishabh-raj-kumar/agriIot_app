import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''{
  "disease": "Tomato Bacterial Spot",
  "image": "assets/images/tomato_bacterial.jpg",
  "symptoms": "Tomato bacterial spot manifests as small, water-soaked spots on leaves, stems, and fruits. These spots quickly become raised, brown, and scab-like with a yellow halo. On leaves, the spots are irregular in shape and may coalesce, leading to leaf distortion and defoliation. On fruits, the spots are slightly raised, rough, and may crack, reducing marketability. Severe infections can lead to significant yield loss and weaken the plant. The disease spreads rapidly under warm, humid conditions.",
  "favorable_environment": "Tomato bacterial spot is caused by the bacteria *Xanthomonas perforans*. It thrives in warm, humid conditions, particularly during periods of rainfall or overhead irrigation. The bacteria can survive in infected plant debris and on seed. Splashing water and wind disperse the bacteria to new plants. Wounds on plants, such as those caused by pruning or handling, provide entry points for the bacteria. Overcrowding of plants and poor air circulation exacerbate the disease. Certain tomato varieties are more susceptible than others, and the disease is more prevalent in regions with warm, wet summers.",
  "management": "1. Use certified disease-free seed and transplants.\\n2. Practice crop rotation with non-host crops to reduce inoculum levels.\\n3. Remove and destroy infected plant debris to minimize overwintering sites for the bacteria.\\n4. Avoid overhead irrigation and water early in the day to allow foliage to dry quickly.\\n5. Ensure proper plant spacing to improve air circulation and reduce humidity.\\n6. Apply copper-based fungicides or bactericides preventatively or at the first signs of infection.\\n7. Use foliar applications according to label directions, but be aware that copper resistance can develop.\\n8. Practice good weed control to minimize competition and improve air circulation.\\n9. Monitor fields regularly for early symptoms, especially during periods of high risk.\\n10. Avoid working in fields when foliage is wet to prevent disease spread."
}
''';

class TomatoDiseaseDetail extends StatelessWidget {
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
