import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

const Map<String, Map<String, String>> grapeBlackRotTranslations = {
  'en': {
    'disease': 'Grape Black Rot',
    'image': 'assets/images/bacterial_blight.jpg',
    'symptoms':
        'Grape black rot initially appears as small, reddish-brown spots on young leaves. These spots rapidly enlarge, becoming circular with a reddish border and a tan to brown center. Tiny black fungal fruiting bodies (pycnidia) develop within the center of the lesions. On shoots and tendrils, elongated, dark brown to black lesions form. Infected berries develop small, brown spots that quickly rot the entire berry, turning it black, hard, and shriveled (mummified). Severe infections can lead to significant yield loss and weaken the vine.',
    'favorable_environment':
        'Grape black rot is caused by the fungus *Guignardia bidwellii*. It thrives in warm, humid conditions, particularly during periods of rainfall or heavy dew. Spores are released from overwintering mummified berries and infected canes, initiating new infections on developing tissues. Young tissues are most susceptible. Poor air circulation and dense canopies create environments that favor fungal growth. Certain grape varieties are more susceptible than others, and the disease is more prevalent in regions with warm, wet springs and summers.',
    'management':
        '1. Remove and destroy mummified berries and infected canes to reduce overwintering inoculum.\\n2. Prune vines to improve air circulation and sunlight penetration.\\n3. Apply fungicides labeled for black rot control before, during, and after bloom.\\n4. Use protectant fungicides, such as captan or mancozeb, before infection periods.\\n5. Apply systemic fungicides, such as myclobutanil or tebuconazole, after infection has occurred.\\n6. Space vines properly to reduce humidity and promote drying.\\n7. Practice good vineyard sanitation to minimize disease spread.\\n8. Monitor weather forecasts and apply fungicides preventatively during periods of high risk.\\n9. Choose grape varieties with some resistance to black rot, if available.\\n10. Ensure adequate drainage in the vineyard to prevent prolonged wetness.',
  },
  'hi': {
    'disease': 'अंगूर काला सड़न',
    'image': 'assets/images/bacterial_blight.jpg',
    'symptoms':
        'अंगूर काला सड़न शुरू में युवा पत्तियों पर छोटे, लाल-भूरे धब्बों के रूप में दिखाई देता है। ये धब्बे तेजी से बढ़ते हैं, लाल सीमा और तन से भूरे केंद्र के साथ गोलाकार हो जाते हैं। घावों के केंद्र में छोटे काले कवक फलने वाले शरीर (पिक्निडिया) विकसित होते हैं। शूट और टेंड्रिल्स पर, लम्बी, गहरे भूरे से काले घाव बनते हैं। संक्रमित जामुन छोटे, भूरे धब्बे विकसित करते हैं जो जल्दी से पूरे बेरी को सड़ा देते हैं, इसे काला, कठोर और मुरझाया हुआ (मम्मीकृत) बना देते हैं। गंभीर संक्रमण से महत्वपूर्ण उपज हानि हो सकती है और बेल कमजोर हो सकती है।',
    'favorable_environment':
        'अंगूर काला सड़न कवक *गुइग्नार्डिया बिडवेलि* के कारण होता है। यह गर्म, आर्द्र परिस्थितियों में पनपता है, खासकर वर्षा या भारी ओस की अवधि के दौरान। बीजाणु सर्दियों में मम्मीकृत जामुन और संक्रमित बेंत से निकलते हैं, जो विकासशील ऊतकों पर नए संक्रमण शुरू करते हैं। युवा ऊतक सबसे अधिक संवेदनशील होते हैं। खराब वायु परिसंचरण और घने चंदवा ऐसे वातावरण बनाते हैं जो कवक के विकास का पक्ष लेते हैं। कुछ अंगूर की किस्में दूसरों की तुलना में अधिक संवेदनशील होती हैं, और गर्म, गीली वसंत और गर्मियों वाले क्षेत्रों में रोग अधिक प्रचलित होता है।',
    'management':
        '1. सर्दियों में इनोक्यूलम को कम करने के लिए मम्मीकृत जामुन और संक्रमित बेंत को हटा दें और नष्ट कर दें।\\n2. वायु परिसंचरण और सूर्य के प्रकाश के प्रवेश में सुधार के लिए बेलों को छाँटें।\\n3. खिलने से पहले, दौरान और बाद में काले सड़न नियंत्रण के लिए लेबल वाले कवकनाशकों को लागू करें।\\n4. संक्रमण अवधि से पहले कैप्टन या मैनकोजेब जैसे सुरक्षात्मक कवकनाशकों का उपयोग करें।\\n5. संक्रमण होने के बाद माइक्लोबुटानिल या टेबुकोनाज़ोल जैसे प्रणालीगत कवकनाशकों को लागू करें।\\n6. आर्द्रता को कम करने और सुखाने को बढ़ावा देने के लिए बेलों को ठीक से स्थान दें।\\n7. रोग के प्रसार को कम करने के लिए अच्छी दाख की बारी स्वच्छता का अभ्यास करें।\\n8. मौसम के पूर्वानुमानों की निगरानी करें और उच्च जोखिम की अवधि के दौरान निवारक रूप से कवकनाशकों को लागू करें।\\n9. यदि उपलब्ध हो तो काले सड़न के लिए कुछ प्रतिरोध के साथ अंगूर की किस्में चुनें।\\n10. लंबे समय तक गीलापन रोकने के लिए दाख की बारी में पर्याप्त जल निकासी सुनिश्चित करें।',
  },
  'bn': {
    'disease': 'আঙ্গুর কালো পচা',
    'image': 'assets/images/bacterial_blight.jpg',
    'symptoms':
        'আঙ্গুর কালো পচা প্রাথমিকভাবে তরুণ পাতার উপর ছোট, লালচে-বাদামী দাগ হিসাবে দেখা দেয়। এই দাগগুলি দ্রুত প্রসারিত হয়, লাল সীমানা এবং ট্যান থেকে বাদামী কেন্দ্র সহ গোলাকার হয়ে যায়। ক্ষতের কেন্দ্রে ক্ষুদ্র কালো ছত্রাক ফলদানকারী শরীর (পিকনিডিয়া) বিকাশ করে। অঙ্কুর এবং টেন্ড্রিলের উপর, দীর্ঘায়িত, গাঢ় বাদামী থেকে কালো ক্ষত তৈরি হয়। সংক্রমিত বেরি ছোট, বাদামী দাগ তৈরি করে যা দ্রুত পুরো বেরিটিকে পচিয়ে দেয়, এটিকে কালো, শক্ত এবং কুঁচকানো (মমিযুক্ত) করে তোলে। গুরুতর সংক্রমণের ফলে উল্লেখযোগ্য ফলন হ্রাস হতে পারে এবং লতা দুর্বল হতে পারে।',
    'favorable_environment':
        'আঙ্গুর কালো পচা *গুইগনার্ডিয়া বিডওয়েল্লি* ছত্রাকের কারণে হয়। এটি উষ্ণ, আর্দ্র পরিস্থিতিতে উন্নতি লাভ করে, বিশেষ করে বৃষ্টিপাত বা ভারী শিশিরের সময়কালে। স্পোরগুলি শীতকালে মমিযুক্ত বেরি এবং সংক্রমিত বেত থেকে নির্গত হয়, যা বিকাশকারী টিস্যুতে নতুন সংক্রমণ শুরু করে। তরুণ টিস্যু সবচেয়ে বেশি সংবেদনশীল। দুর্বল বায়ু সঞ্চালন এবং ঘন ক্যানোপি এমন পরিবেশ তৈরি করে যা ছত্রাকের বৃদ্ধিকে সমর্থন করে। কিছু আঙ্গুরের জাত অন্যদের তুলনায় বেশি সংবেদনশীল, এবং উষ্ণ, ভেজা বসন্ত এবং গ্রীষ্মের অঞ্চলে রোগটি বেশি দেখা যায়।',
    'management':
        '1. শীতকালে ইনোকুলাম কমাতে মমিযুক্ত বেরি এবং সংক্রমিত বেত সরান এবং ধ্বংস করুন।\\n2. বায়ু সঞ্চালন এবং সূর্যালোক অনুপ্রবেশ উন্নত করতে লতা ছাঁটাই করুন।\\n3. ফুল ফোটার আগে, চলাকালীন এবং পরে কালো পচা নিয়ন্ত্রণের জন্য লেবেলযুক্ত ছত্রাকনাশক প্রয়োগ করুন।\\n4. সংক্রমণের সময়কালের আগে ক্যাপটান বা ম্যানকোজেবের মতো প্রতিরক্ষামূলক ছত্রাকনাশক ব্যবহার করুন।\\n5. সংক্রমণ হওয়ার পরে মাইক্লোবুটানিল বা টেবুконаজোলের মতো সিস্টেমিক ছত্রাকনাশক প্রয়োগ করুন।\\n6. আর্দ্রতা কমাতে এবং শুকানো প্রচার করতে সঠিকভাবে লতা স্থান দিন।\\n7. রোগের বিস্তার কমাতে ভাল আঙ্গুরের বাগান স্যানিটেশন অনুশীলন করুন।\\n8. আবহাওয়ার পূর্বাভাস পর্যবেক্ষণ করুন এবং উচ্চ ঝুঁকির সময়কালে প্রতিরোধমূলকভাবে ছত্রাকনাশক প্রয়োগ করুন।\\n9. যদি পাওয়া যায় তবে কালো পচা প্রতিরোধের সাথে আঙ্গুরের জাত নির্বাচন করুন।\\n10. দীর্ঘায়িত ভেজা প্রতিরোধ করতে আঙ্গুরের বাগানে পর্যাপ্ত নিষ্কাশন নিশ্চিত করুন।',
  },
  'ur': {
    'disease': 'انگور سیاہ سڑنا',
    'image': 'assets/images/bacterial_blight.jpg',
    'symptoms':
        'انگور سیاہ سڑنا ابتدائی طور پر جوان پتوں پر چھوٹے، سرخی مائل بھورے دھبوں کی شکل میں ظاہر ہوتا ہے۔ یہ دھبے تیزی سے بڑھتے ہیں، سرخی مائل سرحد اور ٹین سے بھورے مرکز کے ساتھ گول ہو جاتے ہیں۔ گھاووں کے مرکز میں چھوٹے سیاہ فنگل فروٹنگ باڈیز (پکنڈیا) تیار ہوتے ہیں۔ ٹہنیوں اور ٹینڈریلز پر، لمبے، گہرے بھورے سے سیاہ گھاو بنتے ہیں۔ متاثرہ بیر چھوٹے، بھورے دھبے پیدا کرتے ہیں جو جلد ہی پورے بیری کو سڑا دیتے ہیں، اسے سیاہ، سخت اور سکڑے ہوئے (ممی شدہ) بنا دیتے ہیں۔ شدید انفیکشن پیداوار میں نمایاں کمی اور بیل کو کمزور کر سکتے ہیں۔',
    'favorable_environment':
        'انگور سیاہ سڑنا فنگس *گویگنارڈیا بڈویلی* کی وجہ سے ہوتا ہے۔ یہ گرم، مرطوب حالات میں پھلتا پھولتا ہے، خاص طور پر بارش یا بھاری اوس کے ادوار کے دوران۔ بیضے موسم سرما میں ممی شدہ بیر اور متاثرہ ٹہنیوں سے خارج ہوتے ہیں، جو نشوونما پانے والے ٹشوز پر نئے انفیکشن شروع کرتے ہیں۔ جوان ٹشوز سب سے زیادہ حساس ہوتے ہیں۔ ناقص ہوا کی گردش اور گھنے چھتری ایسے ماحول پیدا کرتے ہیں جو فنگل کی نشوونما کے حق میں ہوتے ہیں۔ انگور کی کچھ اقسام دوسروں کے مقابلے میں زیادہ حساس ہوتی ہیں، اور گرم، گیلی بہار اور گرمیوں والے علاقوں میں بیماری زیادہ عام ہے۔',
    'management':
        '1. موسم سرما کے انوکولم کو کم کرنے کے لیے ممی شدہ بیر اور متاثرہ ٹہنیوں کو ہٹا کر تلف کریں۔\\n2. ہوا کی گردش اور سورج کی روشنی کے دخول کو بہتر بنانے کے لیے بیلوں کو تراشیں۔\\n3. پھولنے سے پہلے، دوران اور بعد میں سیاہ سڑنا کنٹرول کے لیے لیبل والے فنگسائڈز لگائیں۔\\n4. انفیکشن کے ادوار سے پہلے حفاظتی فنگسائڈز، جیسے کیپٹن یا مینکوزیب استعمال کریں۔\\n5. انفیکشن ہونے کے بعد نظامی فنگسائڈز، جیسے مائکلوبوٹانیل یا ٹیبوکونازول لگائیں۔\\n6. نمی کو کم کرنے اور خشک کرنے کو فروغ دینے کے لیے بیلوں کو مناسب طریقے سے فاصلہ دیں۔\\n7. بیماری کے پھیلاؤ کو کم کرنے کے لیے اچھی انگور کے باغ کی صفائی کا مشق کریں۔\\n8. موسم کی پیش گوئیوں کی نگرانی کریں اور زیادہ خطرے کے ادوار کے دوران احتیاطی طور پر فنگسائڈز لگائیں۔\\n9. اگر دستیاب ہو تو سیاہ سڑنا کے خلاف کچھ مزاحمت کے ساتھ انگور کی اقسام کا انتخاب کریں۔\\n10. طویل گیلا پن روکنے کے لیے انگور کے باغ میں مناسب نکاسی آب کو یقینی بنائیں۔',
  },
  'ta': {
    'disease': 'திராட்சை கருப்பு அழுகல்',
    'image': 'assets/images/bacterial_blight.jpg',
    'symptoms':
        'திராட்சை கருப்பு அழுகல் ஆரம்பத்தில் இளம் இலைகளில் சிறிய, சிவப்பு-பழுப்பு புள்ளிகளாக தோன்றுகிறது. இந்த புள்ளிகள் வேகமாக பெரிதாகி, சிவப்பு எல்லை மற்றும் பழுப்பு நிற மையத்துடன் வட்டமாக மாறும். புண்களின் மையத்தில் சிறிய கருப்பு பூஞ்சை பழம்தரும் உடல்கள் (பிக்னிடியா) உருவாகின்றன. தளிர்கள் மற்றும் கொடிகள் மீது, நீளமான, அடர் பழுப்பு முதல் கருப்பு புண்கள் உருவாகின்றன. பாதிக்கப்பட்ட பெர்ரி சிறிய, பழுப்பு புள்ளிகளை உருவாக்குகின்றன, அவை விரைவாக முழு பெர்ரியையும் அழுகச் செய்கின்றன, அதை கருப்பு, கடினமான மற்றும் சுருங்கிய (மம்மியாக்கப்பட்டது) ஆக மாற்றுகின்றன. கடுமையான நோய்த்தொற்றுகள் குறிப்பிடத்தக்க விளைச்சல் இழப்புக்கு வழிவகுக்கும் மற்றும் கொடியை பலவீனப்படுத்தும்.',
    'favorable_environment':
        'திராட்சை கருப்பு அழுகல் *குய்னார்டியா பிட்வெல்லி* என்ற பூஞ்சையால் ஏற்படுகிறது. இது வெப்பமான, ஈரப்பதமான சூழ்நிலையில் செழித்து வளர்கிறது, குறிப்பாக மழை அல்லது அதிக பனிப்பொழிவு காலங்களில். குளிர்காலத்தில் மம்மியாக்கப்பட்ட பெர்ரி மற்றும் பாதிக்கப்பட்ட கரும்புகளிலிருந்து ஸ்போர்கள் வெளியிடப்படுகின்றன, இது வளரும் திசுக்களில் புதிய நோய்த்தொற்றுகளைத் தொடங்குகிறது. இளம் திசுக்கள் மிகவும் எளிதில் பாதிக்கப்படுகின்றன. மோசமான காற்று சுழற்சி மற்றும் அடர்த்தியான விதானங்கள் பூஞ்சை வளர்ச்சிக்கு சாதகமான சூழலை உருவாக்குகின்றன. சில திராட்சை வகைகள் மற்றவர்களை விட எளிதில் பாதிக்கப்படுகின்றன, மேலும் வெப்பமான, ஈரமான வசந்த மற்றும் கோடைகாலங்களைக் கொண்ட பகுதிகளில் நோய் மிகவும் பரவலாக உள்ளது.',
    'management':
        '1. குளிர்காலத்தில் இனோகுலத்தை குறைக்க மம்மியாக்கப்பட்ட பெர்ரி மற்றும் பாதிக்கப்பட்ட கரும்புகளை அகற்றி அழிக்கவும்.\\n2. காற்று சுழற்சி மற்றும் சூரிய ஒளி ஊடுருவலை மேம்படுத்த கொடிகளை கத்தரிக்கவும்.\\n3. பூக்கும் முன், போது மற்றும் பின் கருப்பு அழுகல் கட்டுப்பாட்டுக்கு லேபிளிடப்பட்ட பூஞ்சைக் கொல்லிகளைப் பயன்படுத்துங்கள்.\\n4. தொற்று காலங்களுக்கு முன் கேப்டன் அல்லது மான்கோசெப் போன்ற பாதுகாக்கும் பூஞ்சைக் கொல்லிகளைப் பயன்படுத்தவும்.\\n5. தொற்று ஏற்பட்ட பிறகு மைலோபுட்டானில் அல்லது டெபுகோனாசோல் போன்ற முறையான பூஞ்சைக் கொல்லிகளைப் பயன்படுத்துங்கள்.\\n6. ஈரப்பதத்தைக் குறைக்கவும் உலர்த்துவதை ஊக்குவிக்கவும் கொடிகளை சரியாக இடைவெளி விடுங்கள்.\\n7. நோயின் பரவலைக் குறைக்க நல்ல திராட்சைத் தோட்டம் சுகாதாரத்தைப் பயிற்சி செய்யுங்கள்.\\n8. வானிலை முன்னறிவிப்புகளைக் கண்காணிக்கவும் மற்றும் அதிக ஆபத்துள்ள காலங்களில் தடுப்பு பூஞ்சைக் கொல்லிகளைப் பயன்படுத்தவும்.\\n9. முடிந்தால் கருப்பு அழுகலுக்கு சில எதிர்ப்புத் திறன் கொண்ட திராட்சை வகைகளைத் தேர்ந்தெடுக்கவும்.\\n10. நீண்டகால ஈரப்பதத்தைத் தடுக்க திராட்சைத் தோட்டத்தில் போதுமான வடிகால் இருப்பதை உறுதிப்படுத்தவும்.',
  },
};

class GrapDiseaseDetail extends StatefulWidget {
  // Change to StatefulWidget
  @override
  _GrapDiseaseDetailState createState() => _GrapDiseaseDetailState();
}

class _GrapDiseaseDetailState extends State<GrapDiseaseDetail> {
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
    final diseaseData = grapeBlackRotTranslations[
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
