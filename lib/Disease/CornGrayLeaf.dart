import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''
{
  "disease": "Maize Gray Leaf Spot",
  "image": "assets/images/gray_leaf_spot.jpg",
  "symptoms": "Maize gray leaf spot (GLS) initially appears as small, oval to rectangular, tan to gray lesions on the leaves. These lesions run parallel to the leaf veins. As the disease progresses, the lesions elongate and become grayish-brown with a chlorotic (yellow) halo. Under favorable conditions, numerous lesions can coalesce, causing large areas of leaf tissue to die. Severe infections can lead to premature leaf senescence and significant yield loss. Lesions can also develop on leaf sheaths and husks. In humid conditions, tiny black stromata (fungal fruiting bodies) may be visible within the lesions.",
  "favorable_environment": "Maize gray leaf spot is caused by the fungus *Cercospora zeae-maydis*. It thrives in warm, humid conditions with frequent rainfall or heavy dew. The fungus overwinters in infected corn residue, releasing spores in the spring to infect new plants. Reduced tillage practices, which leave more residue on the soil surface, can increase disease pressure. Continuous corn cropping and susceptible corn hybrids also contribute to disease development. The disease is more prevalent in regions with warm, wet summers and high humidity.",
  "management": "1. Choose corn hybrids with resistance to gray leaf spot.\\n2. Practice crop rotation with non-host crops to reduce inoculum levels.\\n3. Implement tillage practices that bury infected corn residue.\\n4. Apply fungicides labeled for gray leaf spot control preventatively or at the first signs of infection.\\n5. Use foliar fungicides, such as strobilurins or triazoles, according to label directions.\\n6. Ensure proper plant spacing to improve air circulation and reduce humidity.\\n7. Monitor fields regularly for early symptoms, especially during periods of high risk.\\n8. Practice good weed control to minimize competition and improve air circulation.\\n9. Consider using biological control agents, such as beneficial fungi, to suppress the pathogen.\\n10. Implement integrated pest management (IPM) strategies to minimize disease development."
}
''';

class CornDisease extends StatelessWidget {
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
