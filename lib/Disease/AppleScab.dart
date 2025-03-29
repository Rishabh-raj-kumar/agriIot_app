import 'package:flutter/material.dart';
import 'dart:convert';

const String DiseaseData = '''
{
  "disease": "Apple Scab",
  "image": "assets/images/apple_scab.jpg",
  "symptoms": "The first visible symptoms of apple scab appear in the spring in the form of minute, circular, olive-green spots on leaves, often along a main vein. As they enlarge, they become brownish-black and eventually coalesce to form large patches of necrotic tissue. As they develop further, they often coalesce and become raised, hard and corky. This restricts the expansion of the fruit and leads to distortion and cracking of the skin that expose the flesh. Light attacks do not affect the fruit quality significantly. However, the scabs can expose the fruits to opportunistic pathogens and rots, reducing the storage capacity and the quality. Affected leaves are often deformed and fall off prematurely, leading to defoliation in case of heavy infections. On shoots, the infections causes blistering and cracking that can then provide entry for opportunistic pathogens. On the fruits, brown to dark brown circular areas appear on the surface.",
  "favorable_environment": "Apple scab is a disease caused by the fungus Venturia inaequalis. It survives the winter mainly on infected leaves on the ground but also on bud scales or lesions on wood. At the onset of spring, the fungus resumes growth and starts to produce spores, which are later discharged and dispersed over long distances by the wind. These spores land on developing leaves and fruits and start a new infection. Outer parts of unopened fruit buds are highly susceptible to scab. However, as the fruit matures it becomes much less susceptible. Humid environment, wetting period of leaves or fruits are essential for the infection. Alternative hosts include shrubs of the genus Cotoneaster, Pyracantha and Sorbus. All apple varieties are susceptible to scab, with Gala being more vulnerable.",
  "management": "1. Use tolerant or resistant varieties.\\n2. Monitor orchards for signs of the disease.\\n3. Pick up affected leaves, shoots and fruits.\\n4. Rake all the fallen leaves from around your trees after harvest.\\n5. Alternatively, apply 5% urea to leaves in the autumn to enhance their decomposition and to obstruct the life cycle of the fungus.\\n6. Excessive leaf litter can can also be mowed to speed up the breakdown of tissues.\\n7. Ensure a pruning method that allow for more air circulation.\\n8. Water in the evening or early morning hours and avoid overhead irrigation.\\n9. Avoid getting foliage wet when watering.\\n10. Apply lime after leaf drop to increase soil pH.\\n11. Spread a mulch under the trees, keeping it away from the trunk."
}
''';

class AppleDisease extends StatelessWidget {
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
