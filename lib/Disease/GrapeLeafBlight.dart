import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''
{
  "disease": "Grape Black Rot",
  "image": "assets/images/bacterial_blight.jpg",
  "symptoms": "Grape black rot initially appears as small, reddish-brown spots on young leaves. These spots rapidly enlarge, becoming circular with a reddish border and a tan to brown center. Tiny black fungal fruiting bodies (pycnidia) develop within the center of the lesions. On shoots and tendrils, elongated, dark brown to black lesions form. Infected berries develop small, brown spots that quickly rot the entire berry, turning it black, hard, and shriveled (mummified). Severe infections can lead to significant yield loss and weaken the vine.",
  "favorable_environment": "Grape black rot is caused by the fungus *Guignardia bidwellii*. It thrives in warm, humid conditions, particularly during periods of rainfall or heavy dew. Spores are released from overwintering mummified berries and infected canes, initiating new infections on developing tissues. Young tissues are most susceptible. Poor air circulation and dense canopies create environments that favor fungal growth. Certain grape varieties are more susceptible than others, and the disease is more prevalent in regions with warm, wet springs and summers.",
  "management": "1. Remove and destroy mummified berries and infected canes to reduce overwintering inoculum.\\n2. Prune vines to improve air circulation and sunlight penetration.\\n3. Apply fungicides labeled for black rot control before, during, and after bloom.\\n4. Use protectant fungicides, such as captan or mancozeb, before infection periods.\\n5. Apply systemic fungicides, such as myclobutanil or tebuconazole, after infection has occurred.\\n6. Space vines properly to reduce humidity and promote drying.\\n7. Practice good vineyard sanitation to minimize disease spread.\\n8. Monitor weather forecasts and apply fungicides preventatively during periods of high risk.\\n9. Choose grape varieties with some resistance to black rot, if available.\\n10. Ensure adequate drainage in the vineyard to prevent prolonged wetness."
}
''';

class GrapDiseaseDetail extends StatelessWidget {
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
