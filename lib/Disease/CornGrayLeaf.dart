import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

const Map<String, Map<String, String>> maizeGrayLeafSpotTranslations = {
  'en': {
    'disease': 'Maize Gray Leaf Spot',
    'image': 'assets/images/gray_leaf_spot.jpg',
    'symptoms':
        'Maize gray leaf spot (GLS) initially appears as small, oval to rectangular, tan to gray lesions on the leaves. These lesions run parallel to the leaf veins. As the disease progresses, the lesions elongate and become grayish-brown with a chlorotic (yellow) halo. Under favorable conditions, numerous lesions can coalesce, causing large areas of leaf tissue to die. Severe infections can lead to premature leaf senescence and significant yield loss. Lesions can also develop on leaf sheaths and husks. In humid conditions, tiny black stromata (fungal fruiting bodies) may be visible within the lesions.',
    'favorable_environment':
        'Maize gray leaf spot is caused by the fungus *Cercospora zeae-maydis*. It thrives in warm, humid conditions with frequent rainfall or heavy dew. The fungus overwinters in infected corn residue, releasing spores in the spring to infect new plants. Reduced tillage practices, which leave more residue on the soil surface, can increase disease pressure. Continuous corn cropping and susceptible corn hybrids also contribute to disease development. The disease is more prevalent in regions with warm, wet summers and high humidity.',
    'management':
        '1. Choose corn hybrids with resistance to gray leaf spot.\\n2. Practice crop rotation with non-host crops to reduce inoculum levels.\\n3. Implement tillage practices that bury infected corn residue.\\n4. Apply fungicides labeled for gray leaf spot control preventatively or at the first signs of infection.\\n5. Use foliar fungicides, such as strobilurins or triazoles, according to label directions.\\n6. Ensure proper plant spacing to improve air circulation and reduce humidity.\\n7. Monitor fields regularly for early symptoms, especially during periods of high risk.\\n8. Practice good weed control to minimize competition and improve air circulation.\\n9. Consider using biological control agents, such as beneficial fungi, to suppress the pathogen.\\n10. Implement integrated pest management (IPM) strategies to minimize disease development.',
  },
  'hi': {
    'disease': 'मक्का ग्रे लीफ स्पॉट',
    'image': 'assets/images/gray_leaf_spot.jpg',
    'symptoms':
        'मक्का ग्रे लीफ स्पॉट (जीएलएस) शुरू में पत्तियों पर छोटे, अंडाकार से आयताकार, तन से ग्रे घावों के रूप में दिखाई देता है। ये घाव पत्ती की नसों के समानांतर चलते हैं। जैसे-जैसे रोग बढ़ता है, घाव लंबे हो जाते हैं और क्लोरोटिक (पीले) प्रभामंडल के साथ भूरे-भूरे रंग के हो जाते हैं। अनुकूल परिस्थितियों में, कई घाव मिलकर पत्ती के ऊतकों के बड़े क्षेत्रों को मार सकते हैं। गंभीर संक्रमण समय से पहले पत्ती के बुढ़ापे और महत्वपूर्ण उपज हानि का कारण बन सकते हैं। घाव पत्ती के आवरण और भूसी पर भी विकसित हो सकते हैं। नम परिस्थितियों में, घावों के भीतर छोटे काले स्ट्रोमाटा (कवक फलने वाले शरीर) दिखाई दे सकते हैं।',
    'favorable_environment':
        'मक्का ग्रे लीफ स्पॉट कवक *सर्कस्पोरा ज़ी-मेडीस* के कारण होता है। यह लगातार बारिश या भारी ओस के साथ गर्म, आर्द्र परिस्थितियों में पनपता है। कवक संक्रमित मकई के अवशेषों में सर्दियों में जीवित रहता है, नए पौधों को संक्रमित करने के लिए वसंत में बीजाणु छोड़ता है। कम जुताई प्रथाएं, जो मिट्टी की सतह पर अधिक अवशेष छोड़ती हैं, रोग के दबाव को बढ़ा सकती हैं। निरंतर मक्का की फसल और अतिसंवेदनशील मक्का संकर भी रोग के विकास में योगदान करते हैं। यह रोग गर्म, गीली गर्मियों और उच्च आर्द्रता वाले क्षेत्रों में अधिक प्रचलित है।',
    'management':
        '1. ग्रे लीफ स्पॉट के प्रतिरोध के साथ मक्का संकर चुनें।\\n2. इनोक्यूलम स्तर को कम करने के लिए गैर-मेजबान फसलों के साथ फसल चक्रण का अभ्यास करें।\\n3. संक्रमित मकई के अवशेषों को दफनाने वाली जुताई प्रथाओं को लागू करें।\\n4. ग्रे लीफ स्पॉट नियंत्रण के लिए लेबल वाले कवकनाशकों को निवारक रूप से या संक्रमण के पहले लक्षणों पर लागू करें।\\n5. लेबल निर्देशों के अनुसार, स्ट्रोबिलुरिन या ट्रायज़ोल जैसे पर्ण कवकनाशकों का उपयोग करें।\\n6. वायु परिसंचरण में सुधार और आर्द्रता को कम करने के लिए उचित पौधे की दूरी सुनिश्चित करें।\\n7. विशेष रूप से उच्च जोखिम की अवधि के दौरान, शुरुआती लक्षणों के लिए नियमित रूप से खेतों की निगरानी करें।\\n8. प्रतिस्पर्धा को कम करने और वायु परिसंचरण में सुधार करने के लिए अच्छी खरपतवार नियंत्रण का अभ्यास करें।\\n9. रोगज़नक़ को दबाने के लिए लाभकारी कवक जैसे जैविक नियंत्रण एजेंटों का उपयोग करने पर विचार करें।\\n10. रोग के विकास को कम करने के लिए एकीकृत कीट प्रबंधन (आईपीएम) रणनीतियों को लागू करें।',
  },
  'bn': {
    'disease': 'ভুট্টা ধূসর পাতার দাগ',
    'image': 'assets/images/gray_leaf_spot.jpg',
    'symptoms':
        'ভুট্টা ধূসর পাতার দাগ (জিএলএস) প্রাথমিকভাবে পাতার উপর ছোট, ডিম্বাকৃতি থেকে আয়তক্ষেত্রাকার, ট্যান থেকে ধূসর ক্ষত হিসাবে দেখা দেয়। এই ক্ষতগুলি পাতার শিরাগুলির সমান্তরালভাবে চলে। রোগের অগ্রগতির সাথে সাথে, ক্ষতগুলি দীর্ঘায়িত হয় এবং ক্লোরোটিক (হলুদ) হ্যালো সহ ধূসর-বাদামী হয়ে যায়। অনুকূল পরিস্থিতিতে, অসংখ্য ক্ষত একত্রিত হতে পারে, যার ফলে পাতার টিস্যুর বড় অংশ মারা যায়। গুরুতর সংক্রমণ অকাল পাতার সেনেসেন্স এবং উল্লেখযোগ্য ফলন হ্রাস করতে পারে। ক্ষত পাতার খাপ এবং তুষেও বিকাশ করতে পারে। আর্দ্র অবস্থায়, ক্ষতের মধ্যে ক্ষুদ্র কালো স্ট্রোমাটা (ছত্রাক ফলদানকারী শরীর) দৃশ্যমান হতে পারে।',
    'favorable_environment':
        'ভুট্টা ধূসর পাতার দাগ *সারকোস্পোরা জিয়া-মেডিজ* ছত্রাকের কারণে হয়। এটি ঘন ঘন বৃষ্টিপাত বা ভারী শিশির সহ উষ্ণ, আর্দ্র পরিস্থিতিতে উন্নতি লাভ করে। ছত্রাক সংক্রমিত ভুট্টার অবশিষ্টাংশে শীতকালে টিকে থাকে, নতুন গাছকে সংক্রমিত করার জন্য বসন্তে স্পোর নির্গত করে। হ্রাসকৃত চাষ পদ্ধতি, যা মাটির পৃষ্ঠে আরও অবশিষ্টাংশ রেখে যায়, রোগের চাপ বাড়িয়ে তুলতে পারে। ক্রমাগত ভুট্টা ফসল এবং সংবেদনশীল ভুট্টা সংকরও রোগের বিকাশে অবদান রাখে। উষ্ণ, ভেজা গ্রীষ্ম এবং উচ্চ আর্দ্রতাযুক্ত অঞ্চলে রোগটি বেশি দেখা যায়।',
    'management':
        '1. ধূসর পাতার দাগের প্রতিরোধ ক্ষমতা সহ ভুট্টা সংকর নির্বাচন করুন।\\n2. ইনোকুলামের মাত্রা কমাতে অ-হোস্ট ফসলের সাথে শস্য ঘূর্ণন অনুশীলন করুন।\\n3. সংক্রমিত ভুট্টার অবশিষ্টাংশ কবর দেয় এমন চাষ পদ্ধতি প্রয়োগ করুন।\\n4. প্রতিরোধমূলকভাবে বা সংক্রমণের প্রথম লক্ষণগুলিতে ধূসর পাতার দাগ নিয়ন্ত্রণের জন্য লেবেলযুক্ত ছত্রাকনাশক প্রয়োগ করুন।\\n5. লেবেলের দিকনির্দেশ অনুসারে, স্ট্রোবিলুরিন বা ট্রায়াজোলগুলির মতো পাতার ছত্রাকনাশক ব্যবহার করুন।\\n6. বায়ু সঞ্চালন উন্নত করতে এবং আর্দ্রতা কমাতে সঠিক উদ্ভিদ ব্যবধান নিশ্চিত করুন।\\n7. বিশেষ করে উচ্চ ঝুঁকির সময়কালে, প্রাথমিক লক্ষণগুলির জন্য নিয়মিত মাঠ পর্যবেক্ষণ করুন।\\n8. প্রতিযোগিতা কমাতে এবং বায়ু সঞ্চালন উন্নত করতে ভাল আগাছা নিয়ন্ত্রণ অনুশীলন করুন।\\n9. রোগজীবাণু দমন করতে উপকারী ছত্রাকের মতো জৈবিক নিয়ন্ত্রণ এজেন্ট ব্যবহার করার কথা বিবেচনা করুন।\\n10. রোগের বিকাশ কমাতে সমন্বিত কীটপতঙ্গ ব্যবস্থাপনা (আইপিএম) কৌশল প্রয়োগ করুন।',
  },
};

class CornDisease extends StatefulWidget {
  // Change to StatefulWidget
  @override
  _CornDiseaseState createState() => _CornDiseaseState();
}

class _CornDiseaseState extends State<CornDisease> {
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguage(); // Load the saved language
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage =
          prefs.getString('language') ?? 'en'; // Get saved language or default
    });
  }

  @override
  Widget build(BuildContext context) {
    final diseaseData = maizeGrayLeafSpotTranslations[
        _selectedLanguage]; // Fetch data based on selected language

    if (diseaseData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('Language data not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseData['disease']!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(diseaseData['image']!),
            SizedBox(height: 16.0),
            Text(
              'Symptoms',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(diseaseData['symptoms']!),
            SizedBox(height: 16.0),
            Text(
              'Favorable Environment',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(diseaseData['favorable_environment']!),
            SizedBox(height: 16.0),
            Text(
              'Management',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(diseaseData['management']!.replaceAll('\\n', '\n')),
          ],
        ),
      ),
    );
  }
}
