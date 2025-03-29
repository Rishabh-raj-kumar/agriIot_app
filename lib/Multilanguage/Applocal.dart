import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Define your translations
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'en': {
      'title': 'AgriIoT',
      'home': 'Home',
      'disease': 'Disease',
      'weather': 'Weather',
      'learn': 'Learn',
      'cropDetails': 'Crop Details',
      'cropName': 'Crop Name: Rice',
      'area': 'Area: 1 Acre',
      'lastIrrigation': 'Last Irrigation: 2 days ago',
      'soilMoisture': 'Soil Moisture: 60%',
      'temperature': 'Temperature: 30°C',
      'humidity': 'Humidity: 70%',
      'irrigateNow': 'Irrigate Now',
      'detectDisease': 'Detect Disease',
      'weatherForAgriculture': 'Weather for Agriculture',
      'location': 'Location: Patna, Bihar',
      'tipsForFarmers': 'Tips for Small Scale Farmers:',
      'learnMore': 'Learn More',
    },
    'hi': {
      'title': 'कृषि आईओटी',
      'home': 'घर',
      'disease': 'रोग',
      'weather': 'मौसम',
      'learn': 'सीखें',
      'cropDetails': 'फसल विवरण',
      'cropName': 'फसल का नाम: चावल',
      'area': 'क्षेत्र: 1 एकड़',
      'lastIrrigation': 'पिछला सिंचाई: 2 दिन पहले',
      'soilMoisture': 'मिट्टी की नमी: 60%',
      'temperature': 'तापमान: 30°C',
      'humidity': 'आर्द्रता: 70%',
      'irrigateNow': 'अभी सिंचाई करें',
      'detectDisease': 'रोग का पता लगाएं',
      'weatherForAgriculture': 'कृषि के लिए मौसम',
      'location': 'स्थान: पटना, बिहार',
      'tipsForFarmers': 'छोटे पैमाने के किसानों के लिए सुझाव:',
      'learnMore': 'और जानें',
    },
    'bn': {
      'title': 'কৃষি আইওটি',
      'home': 'বাড়ি',
      'disease': 'রোগ',
      'weather': 'আবহাওয়া',
      'learn': 'শিখুন',
      'cropDetails': 'ফসলের বিবরণ',
      'cropName': 'ফসলের নাম: ধান',
      'area': 'ক্ষেত্র: ১ একর',
      'lastIrrigation': 'শেষ সেচ: ২ দিন আগে',
      'soilMoisture': 'মাটির আর্দ্রতা: ৬০%',
      'temperature': 'তাপমাত্রা: ৩০°C',
      'humidity': 'আর্দ্রতা: ৭০%',
      'irrigateNow': 'এখন সেচ করুন',
      'detectDisease': 'রোগ সনাক্ত করুন',
      'weatherForAgriculture': 'কৃষির জন্য আবহাওয়া',
      'location': 'অবস্থান: পাটনা, বিহার',
      'tipsForFarmers': 'ছোট কৃষকদের জন্য টিপস:',
      'learnMore': 'আরও জানুন',
    },
    'ur': {
      'title': 'زرعی آئی او ٹی',
      'home': 'گھر',
      'disease': 'بیماری',
      'weather': 'موسم',
      'learn': 'سیکھیں',
      'cropDetails': 'فصل کی تفصیلات',
      'cropName': 'فصل کا نام: چاول',
      'area': 'رقبہ: 1 ایکڑ',
      'lastIrrigation': 'آخری آبپاشی: 2 دن پہلے',
      'soilMoisture': 'مٹی کی نمی: 60%',
      'temperature': 'درجہ حرارت: 30°C',
      'humidity': 'نمی: 70%',
      'irrigateNow': 'اب آبپاشی کریں',
      'detectDisease': 'بیماری کا پتہ لگائیں',
      'weatherForAgriculture': 'زراعت کے لیے موسم',
      'location': 'مقام: پٹنہ، بہار',
      'tipsForFarmers': 'چھوٹے پیمانے کے کسانوں کے لیے تجاویز:',
      'learnMore': 'مزید جانیں',
    },
    'te': {
      'title': 'వ్యవసాయ ఐఓటీ',
      'home': 'ఇల్లు',
      'disease': 'వ్యాధి',
      'weather': 'వాతావరణం',
      'learn': 'నేర్చుకోండి',
      'cropDetails': 'పంట వివరాలు',
      'cropName': 'పంట పేరు: వరి',
      'area': 'ప్రాంతం: 1 ఎకరం',
      'lastIrrigation': 'చివరి నీటిపారుదల: 2 రోజుల క్రితం',
      'soilMoisture': 'నేల తేమ: 60%',
      'temperature': 'ఉష్ణోగ్రత: 30°C',
      'humidity': 'తేమ: 70%',
      'irrigateNow': 'ఇప్పుడే నీరు పెట్టండి',
      'detectDisease': 'వ్యాధిని గుర్తించండి',
      'weatherForAgriculture': 'వ్యవసాయానికి వాతావరణం',
      'location': 'స్థానం: పాట్నా, బీహార్',
      'tipsForFarmers': 'చిన్న తరహా రైతుల కోసం చిట్కాలు:',
      'learnMore': 'మరింత తెలుసుకోండి',
    },
  };

  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get disease => _localizedValues[locale.languageCode]!['disease']!;
  String get weather => _localizedValues[locale.languageCode]!['weather']!;
  String get learn => _localizedValues[locale.languageCode]!['learn']!;
  String get cropDetails =>
      _localizedValues[locale.languageCode]!['cropDetails']!;
  String get cropName => _localizedValues[locale.languageCode]!['cropName']!;
  String get area => _localizedValues[locale.languageCode]!['area']!;
  String get lastIrrigation =>
      _localizedValues[locale.languageCode]!['lastIrrigation']!;
  String get soilMoisture =>
      _localizedValues[locale.languageCode]!['soilMoisture']!;
  String get temperature =>
      _localizedValues[locale.languageCode]!['temperature']!;
  String get humidity => _localizedValues[locale.languageCode]!['humidity']!;
  String get irrigateNow =>
      _localizedValues[locale.languageCode]!['irrigateNow']!;
  String get detectDisease =>
      _localizedValues[locale.languageCode]!['detectDisease']!;
  String get weatherForAgriculture =>
      _localizedValues[locale.languageCode]!['weatherForAgriculture']!;
  String get location => _localizedValues[locale.languageCode]!['location']!;
  String get tipsForFarmers =>
      _localizedValues[locale.languageCode]!['tipsForFarmers']!;
  String get learnMore => _localizedValues[locale.languageCode]!['learnMore']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hi', 'bn', 'ur', 'te'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
