import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

const Map<String, Map<String, String>> cherryPowderyMildewTranslations = {
  'en': {
    'disease': 'Cherry Powdery Mildew',
    'image': 'assets/images/cherry_powdery.jpg',
    'symptoms':
        'Cherry powdery mildew manifests as white to grayish, powdery patches on the leaves, stems, and occasionally fruits. These patches consist of fungal mycelium and spores. Young leaves are particularly susceptible, and severe infections can cause leaf distortion, curling, and premature drop. On fruits, the mildew can lead to russeting and cracking, reducing their marketability. The white patches can spread rapidly under favorable conditions, covering large portions of the plant. In severe cases, it can inhibit photosynthesis and overall plant growth.',
    'favorable_environment':
        'Cherry powdery mildew thrives in warm, dry conditions, particularly when nights are cool and days are warm. High humidity and poor air circulation exacerbate the disease. Overcrowding of plants and excessive nitrogen fertilization can also create a favorable environment for the fungus. The fungus overwinters in dormant buds and on fallen debris, releasing spores in the spring to initiate new infections. Certain cherry varieties are more susceptible than others, and the disease tends to be more severe in regions with mild winters and dry summers.',
    'management':
        '1. Choose resistant cherry varieties whenever possible.\\n2. Ensure proper spacing between plants to improve air circulation.\\n3. Prune trees to remove infected branches and open up the canopy.\\n4. Rake and remove fallen leaves and debris to eliminate overwintering sites for the fungus.\\n5. Apply fungicides labeled for powdery mildew control at the first signs of infection.\\n6. Use sulfur-based fungicides or horticultural oils as preventive measures.\\n7. Avoid excessive nitrogen fertilization, which promotes lush growth susceptible to infection.\\n8. Monitor plants regularly for early symptoms and take prompt action.\\n9. Provide adequate irrigation to maintain plant health, but avoid overhead watering, which can increase humidity.\\n10. Consider using biological control agents, such as beneficial fungi, to suppress powdery mildew.',
  },
  'hi': {
    'disease': 'चेरी चूर्णिल आसिता',
    'image': 'assets/images/cherry_powdery.jpg',
    'symptoms':
        'चेरी चूर्णिल आसिता पत्तियों, तनों और कभी-कभी फलों पर सफेद से भूरे रंग के, पाउडर जैसे धब्बों के रूप में प्रकट होती है। ये धब्बे कवक मायसेलियम और बीजाणुओं से बने होते हैं। युवा पत्तियां विशेष रूप से अतिसंवेदनशील होती हैं, और गंभीर संक्रमण से पत्ती विकृति, घुमाव और समय से पहले गिर सकती हैं। फलों पर, चूर्णिल आसिता रुसेटिंग और दरार का कारण बन सकती है, जिससे उनकी बाजार क्षमता कम हो जाती है। सफेद धब्बे अनुकूल परिस्थितियों में तेजी से फैल सकते हैं, जिससे पौधे के बड़े हिस्से ढक जाते हैं। गंभीर मामलों में, यह प्रकाश संश्लेषण और समग्र पौधे की वृद्धि को बाधित कर सकता है।',
    'favorable_environment':
        'चेरी चूर्णिल आसिता गर्म, शुष्क परिस्थितियों में पनपती है, खासकर जब रातें ठंडी और दिन गर्म होते हैं। उच्च आर्द्रता और खराब वायु परिसंचरण रोग को बढ़ा देते हैं। पौधों की भीड़ और अत्यधिक नाइट्रोजन निषेचन भी कवक के लिए अनुकूल वातावरण बना सकते हैं। कवक निष्क्रिय कलियों और गिरे हुए मलबे में सर्दियों में जीवित रहता है, वसंत में नए संक्रमण शुरू करने के लिए बीजाणु छोड़ता है। कुछ चेरी किस्में दूसरों की तुलना में अधिक अतिसंवेदनशील होती हैं, और हल्के सर्दियों और शुष्क गर्मियों वाले क्षेत्रों में रोग अधिक गंभीर होता है।',
    'management':
        '1. जब भी संभव हो प्रतिरोधी चेरी किस्मों का चयन करें।\\n2. वायु परिसंचरण में सुधार के लिए पौधों के बीच उचित दूरी सुनिश्चित करें।\\n3. संक्रमित शाखाओं को हटाने और चंदवा खोलने के लिए पेड़ों को छाँटें।\\n4. कवक के लिए सर्दियों के स्थलों को खत्म करने के लिए गिरे हुए पत्तों और मलबे को रेक और हटा दें।\\n5. संक्रमण के पहले लक्षणों पर चूर्णिल आसिता नियंत्रण के लिए लेबल वाले कवकनाशी लागू करें।\\n6. निवारक उपायों के रूप में सल्फर-आधारित कवकनाशी या बागवानी तेलों का उपयोग करें।\\n7. अत्यधिक नाइट्रोजन निषेचन से बचें, जो संक्रमण के लिए अतिसंवेदनशील रसीला विकास को बढ़ावा देता है।\\n8. शुरुआती लक्षणों के लिए नियमित रूप से पौधों की निगरानी करें और तुरंत कार्रवाई करें।\\n9. पौधे के स्वास्थ्य को बनाए रखने के लिए पर्याप्त सिंचाई प्रदान करें, लेकिन ओवरहेड वाटरिंग से बचें, जो आर्द्रता को बढ़ा सकता है।\\n10. चूर्णिल आसिता को दबाने के लिए लाभकारी कवक जैसे जैविक नियंत्रण एजेंटों का उपयोग करने पर विचार करें।',
  },
  'bn': {
    'disease': 'চেরি পাউডারি মিলডিউ',
    'image': 'assets/images/cherry_powdery.jpg',
    'symptoms':
        'চেরি পাউডারি মিলডিউ পাতা, কান্ড এবং মাঝে মাঝে ফলের উপর সাদা থেকে ধূসর, গুঁড়ো প্যাচ হিসাবে প্রকাশ পায়। এই প্যাচগুলি ছত্রাক মাইসেলিয়াম এবং স্পোর নিয়ে গঠিত। অল্প বয়স্ক পাতা বিশেষভাবে সংবেদনশীল, এবং গুরুতর সংক্রমণের কারণে পাতার বিকৃতি, কোঁকড়ানো এবং অকাল পতন হতে পারে। ফলগুলিতে, মিলডিউ রুসেটিং এবং ফাটল সৃষ্টি করতে পারে, যা তাদের বাজারযোগ্যতা হ্রাস করে। সাদা প্যাচগুলি অনুকূল পরিস্থিতিতে দ্রুত ছড়িয়ে পড়তে পারে, যা উদ্ভিদের বড় অংশগুলিকে ঢেকে দেয়। গুরুতর ক্ষেত্রে, এটি সালোকসংশ্লেষণ এবং সামগ্রিক উদ্ভিদ বৃদ্ধিকে বাধা দিতে পারে।',
    'favorable_environment':
        'চেরি পাউডারি মিলডিউ উষ্ণ, শুষ্ক পরিস্থিতিতে উন্নতি লাভ করে, বিশেষ করে যখন রাত ঠান্ডা এবং দিন উষ্ণ থাকে। উচ্চ আর্দ্রতা এবং দুর্বল বায়ু সঞ্চালন রোগকে বাড়িয়ে তোলে। উদ্ভিদের ভিড় এবং অতিরিক্ত নাইট্রোজেন সার প্রয়োগ ছত্রাকের জন্য অনুকূল পরিবেশ তৈরি করতে পারে। ছত্রাক সুপ্ত কুঁড়ি এবং পড়ে যাওয়া ধ্বংসাবশেষে শীতকালে টিকে থাকে, নতুন সংক্রমণ শুরু করার জন্য বসন্তে স্পোর নির্গত করে। কিছু চেরি জাত অন্যদের তুলনায় বেশি সংবেদনশীল, এবং হালকা শীত এবং শুষ্ক গ্রীষ্মের অঞ্চলে রোগটি আরও গুরুতর হওয়ার প্রবণতা থাকে।',
    'management':
        '1. যখনই সম্ভব প্রতিরোধী চেরি জাত নির্বাচন করুন।\\n2. বায়ু সঞ্চালন উন্নত করতে উদ্ভিদের মধ্যে সঠিক ব্যবধান নিশ্চিত করুন।\\n3. সংক্রমিত শাখা অপসারণ এবং ক্যানোপি খোলার জন্য গাছ ছাঁটাই করুন।\\n4. ছত্রাকের জন্য শীতকালীন সাইটগুলি দূর করতে পড়ে যাওয়া পাতা এবং ধ্বংসাবশেষ সংগ্রহ এবং অপসারণ করুন।\\n5. সংক্রমণের প্রথম লক্ষণগুলিতে পাউডারি মিলডিউ নিয়ন্ত্রণের জন্য লেবেলযুক্ত ছত্রাকনাশক প্রয়োগ করুন।\\n6. প্রতিরোধমূলক ব্যবস্থা হিসাবে সালফার-ভিত্তিক ছত্রাকনাশক বা উদ্যান তেল ব্যবহার করুন।\\n7. অতিরিক্ত নাইট্রোজেন সার প্রয়োগ এড়িয়ে চলুন, যা সংক্রমণের জন্য সংবেদনশীল রসালো বৃদ্ধিকে উৎসাহিত করে।\\n8. প্রাথমিক লক্ষণগুলির জন্য নিয়মিত উদ্ভিদ পর্যবেক্ষণ করুন এবং দ্রুত পদক্ষেপ নিন।\\n9. উদ্ভিদের স্বাস্থ্য বজায় রাখার জন্য পর্যাপ্ত সেচ প্রদান করুন, তবে ওভারহেড জল দেওয়া এড়িয়ে চলুন, যা আর্দ্রতা বাড়িয়ে তুলতে পারে।\\n10. পাউডারি মিলডিউ দমন করার জন্য উপকারী ছত্রাকের মতো জৈবিক নিয়ন্ত্রণ এজেন্ট ব্যবহার করার কথা বিবেচনা করুন।',
  },
  'ur': {
    'disease': 'چیری پاؤڈری ملڈیو',
    'image': 'assets/images/cherry_powdery.jpg',
    'symptoms':
        'چیری پاؤڈری ملڈیو پتوں، تنوں اور کبھی کبھار پھلوں پر سفید سے سرمئی، پاؤڈر جیسے دھبوں کی شکل میں ظاہر ہوتا ہے۔ یہ دھبے فنگل مائسیلیم اور بیضوں پر مشتمل ہوتے ہیں۔ نوجوان پتے خاص طور پر حساس ہوتے ہیں، اور شدید انفیکشن پتوں کی خرابی، کرلنگ اور قبل از وقت گرنے کا سبب بن سکتے ہیں۔ پھلوں پر، ملڈیو روسٹنگ اور کریکنگ کا باعث بن سکتا ہے، جس سے ان کی مارکیٹنگ کم ہو جاتی ہے۔ سفید دھبے سازگار حالات میں تیزی سے پھیل سکتے ہیں، جو پودے کے بڑے حصوں کو ڈھانپ لیتے ہیں۔ شدید صورتوں میں، یہ فوٹو سنتھیسز اور پودوں کی مجموعی نشوونما کو روک سکتا ہے۔',
    'favorable_environment':
        'چیری پاؤڈری ملڈیو گرم، خشک حالات میں پھلتا پھولتا ہے، خاص طور پر جب راتیں ٹھنڈی اور دن گرم ہوں۔ زیادہ نمی اور ناقص ہوا کی گردش بیماری کو بڑھا دیتی ہے۔ پودوں کا زیادہ ہجوم اور ضرورت سے زیادہ نائٹروجن کی کھاد بھی فنگس کے لیے سازگار ماحول پیدا کر سکتی ہے۔ فنگس غیر فعال کلیوں اور گرے ہوئے ملبے میں سردیوں میں زندہ رہتا ہے، نئے انفیکشن شروع کرنے کے لیے بہار میں بیضے چھوڑتا ہے۔ کچھ چیری کی اقسام دوسروں کے مقابلے میں زیادہ حساس ہوتی ہیں، اور ہلکی سردیوں اور خشک گرمیوں والے علاقوں میں بیماری زیادہ شدید ہوتی ہے۔',
    'management':
        '1. جب بھی ممکن ہو مزاحم چیری کی اقسام کا انتخاب کریں۔\\n2. ہوا کی گردش کو بہتر بنانے کے لیے پودوں کے درمیان مناسب فاصلہ یقینی بنائیں۔\\n3. متاثرہ شاخوں کو ہٹانے اور چھتری کھولنے کے لیے درختوں کو تراشیں۔\\n4. فنگس کے لیے موسم سرما کے مقامات کو ختم کرنے کے لیے گرے ہوئے پتوں اور ملبے کو جمع اور ہٹا دیں۔\\n5. انفیکشن کے پہلے آثار پر پاؤڈری ملڈیو کنٹرول کے لیے لیبل والے فنگسائڈز لگائیں۔\\n6. احتیاطی تدابیر کے طور پر سلفر پر مبنی فنگسائڈز یا باغبانی کے تیل استعمال کریں۔\\n7. ضرورت سے زیادہ نائٹروجن کی کھاد سے پرہیز کریں، جو انفیکشن کے لیے حساس سرسبز نشوونما کو فروغ دیتی ہے۔\\n8. ابتدائی علامات کے لیے باقاعدگی سے پودوں کی نگرانی کریں اور فوری کارروائی کریں۔\\n9. پودوں کی صحت کو برقرار رکھنے کے لیے مناسب آبپاشی فراہم کریں، لیکن اوور ہیڈ واٹرنگ سے پرہیز کریں، جو نمی کو بڑھا سکتا ہے۔\\n10. پاؤڈری ملڈیو کو دبانے کے لیے حیاتیاتی کنٹرول ایجنٹس، جیسے فائدہ مند فنگس، استعمال کرنے پر غور کریں۔',
  },
  'ta': {
    'disease': 'செர்ரி பவுடரி பூஞ்சை காளான்',
    'image': 'assets/images/cherry_powdery.jpg',
    'symptoms':
        'செர்ரி பவுடரி பூஞ்சை காளான் இலைகள், தண்டுகள் மற்றும் எப்போதாவது பழங்களில் வெள்ளை முதல் சாம்பல் நிற, தூள் திட்டுகளாக வெளிப்படுகிறது। இந்த திட்டுகள் பூஞ்சை மைசீலியம் மற்றும் ஸ்போர்களைக் கொண்டிருக்கின்றன। இளம் இலைகள் குறிப்பாக பாதிக்கப்படக்கூடியவை, மேலும் கடுமையான நோய்த்தொற்றுகள் இலை சிதைவு, சுருட்டை மற்றும் முன்கூட்டியே வீழ்ச்சியை ஏற்படுத்தும்। பழங்களில், பூஞ்சை காளான் ரூசெட்டிங் மற்றும் விரிசல் ஏற்படலாம், இது அவற்றின் சந்தைப்படுத்தலைக் குறைக்கிறது। வெள்ளை திட்டுகள் சாதகமான சூழ்நிலையில் வேகமாக பரவி, தாவரத்தின் பெரிய பகுதிகளை உள்ளடக்கும்। கடுமையான சந்தர்ப்பங்களில், இது ஒளிச்சேர்க்கை மற்றும் ஒட்டுமொத்த தாவர வளர்ச்சியைத் தடுக்கலாம்।',
    'favorable_environment':
        'செர்ரி பவுடரி பூஞ்சை காளான் வெப்பமான, வறண்ட சூழ்நிலையில் செழித்து வளர்கிறது, குறிப்பாக இரவுகள் குளிர்ச்சியாகவும், பகல் வெப்பமாகவும் இருக்கும்போது। அதிக ஈரப்பதம் மற்றும் மோசமான காற்று சுழற்சி நோயை அதிகப்படுத்துகிறது। தாவரங்களின் அதிக நெரிசல் மற்றும் அதிகப்படியான நைட்ரஜன் உரமிடுதல் பூஞ்சைக்கு சாதகமான சூழலை உருவாக்கலாம்। பூஞ்சை செயலற்ற மொட்டுகள் மற்றும் விழுந்த குப்பைகளில் குளிர்காலத்தில் உயிர்வாழ்கிறது, புதிய நோய்த்தொற்றுகளைத் தொடங்க வசந்த காலத்தில் ஸ்போர்களை வெளியிடுகிறது। சில செர்ரி வகைகள் மற்றவர்களை விட எளிதில் பாதிக்கப்படுகின்றன, மேலும் லேசான குளிர்காலம் மற்றும் வறண்ட கோடைகாலங்களைக் கொண்ட பகுதிகளில் நோய் மிகவும் கடுமையானதாக இருக்கும்।',
    'management':
        '1. முடிந்தவரை எதிர்ப்பு செர்ரி வகைகளைத் தேர்வு செய்யவும்।\\n2. காற்று சுழற்சியை மேம்படுத்த தாவரங்களுக்கு இடையே சரியான இடைவெளியை உறுதிப்படுத்தவும்।\\n3. பாதிக்கப்பட்ட கிளைகளை அகற்றவும் விதானத்தை திறக்கவும் மரங்களை கத்தரிக்கவும்।\\n4. பூஞ்சைக்கு குளிர்கால தளங்களை அகற்ற விழுந்த இலைகள் மற்றும் குப்பைகளை அள்ளவும் அகற்றவும்।\\n5. நோய்த்தொற்றின் முதல் அறிகுறிகளில் பவுடரி பூஞ்சை காளான் கட்டுப்பாட்டுக்கு லேபிளிடப்பட்ட பூஞ்சைக் கொல்லிகளைப் பயன்படுத்துங்கள்।\\n6. தடுப்பு நடவடிக்கைகளாக சல்பர் அடிப்படையிலான பூஞ்சைக் கொல்லிகள் அல்லது தோட்டக்கலை எண்ணெய்களைப் பயன்படுத்துங்கள்।\\n7. நோய்த்தொற்றுகளுக்கு ஆளாகும் பசுமையான வளர்ச்சியை ஊக்குவிக்கும் அதிகப்படியான நைட்ரஜன் உரமிடுவதைத் தவிர்க்கவும்।\\n8. ஆரம்ப அறிகுறிகளுக்கு தாவரங்களை தவறாமல் கண்காணிக்கவும் உடனடியாக நடவடிக்கை எடுக்கவும்।\\n9. தாவர ஆரோக்கியத்தை பராமரிக்க போதுமான நீர்ப்பாசனம் வழங்கவும், ஆனால் மேல்நிலை நீர்ப்பாசனத்தை தவிர்க்கவும், இது ஈரப்பதத்தை அதிகரிக்கும்।\\n10. பவுடரி பூஞ்சை காளானை அடக்க நன்மை பயக்கும் பூஞ்சைகள் போன்ற உயிரியல் கட்டுப்பாட்டு முகவர்களைப் பயன்படுத்துவதைக் கவனியுங்கள்।',
  },
};

class CherryDiseaseDetail extends StatefulWidget {
  // Change to StatefulWidget
  @override
  _CherryDiseaseDetailState createState() => _CherryDiseaseDetailState();
}

class _CherryDiseaseDetailState extends State<CherryDiseaseDetail> {
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
    final diseaseData = cherryPowderyMildewTranslations[
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
