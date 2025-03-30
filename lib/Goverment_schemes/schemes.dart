import 'package:agriculture/Multilanguage/Applocal.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const Map<String, dynamic> agricultureSchemesTranslations = {
  'en': [
    {
      "schemeName": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
      "description":
          "Provides income support to all landholding farmer families across the country, with cultivable landholding, subject to certain exclusions.",
      "benefits":
          "Rs. 6000 per year, in three equal installments, directly into the farmers' bank accounts.",
      "eligibility":
          "All landholding farmer families with cultivable land, subject to exclusions like income tax payers and institutional landholders.",
      "website": "https://pmkisan.gov.in/"
    },
    {
      "schemeName": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
      "description":
          "Provides comprehensive risk insurance coverage to farmers for losses suffered due to natural calamities.",
      "benefits":
          "Insurance coverage for crop loss due to non-preventable natural risks.",
      "eligibility": "All farmers growing notified crops in notified areas.",
      "website": "https://pmfby.gov.in/"
    },
    {
      "schemeName": "Soil Health Card Scheme",
      "description":
          "Provides soil health cards to farmers, containing information about soil nutrient status and recommendations for appropriate fertilizer use.",
      "benefits":
          "Improved soil health, reduced input costs, and increased crop productivity.",
      "eligibility": "All farmers owning agricultural land.",
      "website": "https://soilhealth.dac.gov.in/"
    },
    {
      "schemeName": "Paramparagat Krishi Vikas Yojana (PKVY)",
      "description":
          "Promotes organic farming through cluster formation and capacity building of farmers.",
      "benefits":
          "Financial assistance for organic farming, improved soil health, and access to organic markets.",
      "eligibility": "Groups of farmers adopting organic farming practices.",
      "website": "https://pgsindia-ncof.gov.in/"
    },
    {
      "schemeName": "Kisan Credit Card (KCC)",
      "description":
          "Provides farmers with easy access to credit for agricultural inputs and other needs.",
      "benefits":
          "Credit at concessional interest rates, flexible repayment options.",
      "eligibility": "Farmers engaged in agriculture and allied activities.",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
    },
    {
      "schemeName": "National Agriculture Market (eNAM)",
      "description":
          "A pan-India electronic trading portal that networks the existing Agricultural Produce Market Committees (APMCs) to create a unified national market for agricultural commodities.",
      "benefits":
          "Better price discovery, transparent auction process, and reduced transaction costs.",
      "eligibility": "Farmers and traders registered with eNAM.",
      "website": "https://enam.gov.in/web/"
    },
    {
      "schemeName": "Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)",
      "description":
          "Aims to enhance physical access of water on farm and expand cultivable area under assured irrigation, improve on farm water use efficiency, introduce sustainable water conservation practices etc.",
      "benefits":
          "Improved irrigation facilities, water conservation, and enhanced crop productivity.",
      "eligibility": "All farmers with agricultural land.",
      "website": "https://pmksy.gov.in/"
    },
    {
      "schemeName": "Mission for Integrated Development of Horticulture (MIDH)",
      "description":
          "Aims to promote holistic growth of the horticulture sector, including fruits, vegetables, root and tuber crops, mushrooms, spices, flowers, aromatic plants, coconut, cashew, bamboo and honey.",
      "benefits":
          "Financial assistance for horticulture development, improved productivity, and market access.",
      "eligibility": "Farmers and entrepreneurs engaged in horticulture.",
      "website": "https://midh.gov.in/"
    },
    {
      "schemeName": "Rashtriya Krishi Vikas Yojana (RKVY)",
      "description":
          "Aims to achieve 4% annual growth in the agriculture sector by ensuring holistic development of agriculture and allied sectors.",
      "benefits":
          "Financial assistance for agricultural development projects and infrastructure.",
      "eligibility": "State governments and agricultural institutions.",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
    },
    {
      "schemeName": "National Food Security Mission (NFSM)",
      "description":
          "Aims to increase production of rice, wheat, pulses, coarse cereals and nutri-cereals through area expansion and productivity enhancement.",
      "benefits":
          "Increased food production and availability, improved farmer income.",
      "eligibility": "All farmers engaged in the production of notified crops.",
      "website": "https://nfsm.gov.in/"
    }
  ],
  'hi': [
    {
      "schemeName": "प्रधानमंत्री किसान सम्मान निधि (पीएम-किसान)",
      "description":
          "कुछ बहिष्करणों के अधीन, देश भर में सभी भूमिधारक किसान परिवारों को उनकी कृषि योग्य भूमि के साथ आय सहायता प्रदान करता है।",
      "benefits":
          "किसानों के बैंक खातों में सीधे तीन समान किस्तों में प्रति वर्ष 6000 रुपये।",
      "eligibility":
          "कृषि योग्य भूमि वाले सभी भूमिधारक किसान परिवार, आय करदाताओं और संस्थागत भूमिधारकों जैसे बहिष्करणों के अधीन।",
      "website": "https://pmkisan.gov.in/"
    },
    {
      "schemeName": "प्रधानमंत्री फसल बीमा योजना (पीएमएफबीवाई)",
      "description":
          "प्राकृतिक आपदाओं के कारण होने वाले नुकसान के लिए किसानों को व्यापक जोखिम बीमा कवरेज प्रदान करता है।",
      "benefits":
          "गैर-रोकथाम योग्य प्राकृतिक जोखिमों के कारण फसल हानि के लिए बीमा कवरेज।",
      "eligibility":
          "अधिसूचित क्षेत्रों में अधिसूचित फसलें उगाने वाले सभी किसान।",
      "website": "https://pmfby.gov.in/"
    },
    {
      "schemeName": "मृदा स्वास्थ्य कार्ड योजना",
      "description":
          "किसानों को मृदा स्वास्थ्य कार्ड प्रदान करता है, जिसमें मृदा पोषक तत्वों की स्थिति और उचित उर्वरक उपयोग के लिए सिफारिशों के बारे में जानकारी होती है।",
      "benefits":
          "मृदा स्वास्थ्य में सुधार, इनपुट लागत में कमी और फसल उत्पादकता में वृद्धि।",
      "eligibility": "कृषि भूमि वाले सभी किसान।",
      "website": "https://soilhealth.dac.gov.in/"
    },
    {
      "schemeName": "परंपरागत कृषि विकास योजना (पीकेवीवाई)",
      "description":
          "किसानों के समूहों के गठन और क्षमता निर्माण के माध्यम से जैविक खेती को बढ़ावा देता है।",
      "benefits":
          "जैविक खेती के लिए वित्तीय सहायता, मृदा स्वास्थ्य में सुधार और जैविक बाजारों तक पहुंच।",
      "eligibility": "जैविक कृषि पद्धतियों को अपनाने वाले किसानों के समूह।",
      "website": "https://pgsindia-ncof.gov.in/"
    },
    {
      "schemeName": "किसान क्रेडिट कार्ड (केसीसी)",
      "description":
          "किसानों को कृषि आदानों और अन्य आवश्यकताओं के लिए ऋण तक आसान पहुंच प्रदान करता है।",
      "benefits": "रियायती ब्याज दरों पर ऋण, लचीले पुनर्भुगतान विकल्प।",
      "eligibility": "कृषि और संबद्ध गतिविधियों में लगे किसान।",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
    },
    {
      "schemeName": "राष्ट्रीय कृषि बाजार (ई-नाम)",
      "description":
          "एक अखिल भारतीय इलेक्ट्रॉनिक ट्रेडिंग पोर्टल जो कृषि वस्तुओं के लिए एक एकीकृत राष्ट्रीय बाजार बनाने के लिए मौजूदा कृषि उपज बाजार समितियों (एपीएमसी) को नेटवर्क करता है।",
      "benefits":
          "बेहतर मूल्य खोज, पारदर्शी नीलामी प्रक्रिया और कम लेनदेन लागत।",
      "eligibility": "ई-नाम के साथ पंजीकृत किसान और व्यापारी।",
      "website": "https://enam.gov.in/web/"
    },
    {
      "schemeName": "प्रधानमंत्री कृषि सिंचाई योजना (पीएमकेएसवाई)",
      "description":
          "खेत पर पानी की भौतिक पहुंच बढ़ाने और सुनिश्चित सिंचाई के तहत कृषि योग्य क्षेत्र का विस्तार करने, खेत पर पानी के उपयोग की दक्षता में सुधार करने, टिकाऊ जल संरक्षण प्रथाओं को शुरू करने आदि का लक्ष्य है।",
      "benefits":
          "सिंचाई सुविधाओं में सुधार, जल संरक्षण और फसल उत्पादकता में वृद्धि।",
      "eligibility": "कृषि भूमि वाले सभी किसान।",
      "website": "https://pmksy.gov.in/"
    },
    {
      "schemeName": "बागवानी के एकीकृत विकास के लिए मिशन (एमआईडीएच)",
      "description":
          "फल, सब्जियां, जड़ और कंद फसलें, मशरूम, मसाले, फूल, सुगंधित पौधे, नारियल, काजू, बांस और शहद सहित बागवानी क्षेत्र के समग्र विकास को बढ़ावा देना है।",
      "benefits":
          "बागवानी विकास, बेहतर उत्पादकता और बाजार पहुंच के लिए वित्तीय सहायता।",
      "eligibility": "बागवानी में लगे किसान और उद्यमी।",
      "website": "https://midh.gov.in/"
    },
    {
      "schemeName": "राष्ट्रीय कृषि विकास योजना (आरकेवीवाई)",
      "description":
          "कृषि और संबद्ध क्षेत्रों के समग्र विकास को सुनिश्चित करके कृषि क्षेत्र में 4% वार्षिक वृद्धि प्राप्त करना है।",
      "benefits":
          "कृषि विकास परियोजनाओं और बुनियादी ढांचे के लिए वित्तीय सहायता।",
      "eligibility": "राज्य सरकारें और कृषि संस्थान।",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
    },
    {
      "schemeName": "राष्ट्रीय खाद्य सुरक्षा मिशन (एनएफएसएम)",
      "description":
          "क्षेत्र विस्तार और उत्पादकता वृद्धि के माध्यम से चावल, गेहूं, दलहन, मोटे अनाज और पोषक अनाज के उत्पादन को बढ़ाना है।",
      "benefits":
          "खाद्य उत्पादन और उपलब्धता में वृद्धि, किसानों की आय में सुधार।",
      "eligibility": "अधिसूचित फसलों के उत्पादन में लगे सभी किसान।",
      "website": "https://nfsm.gov.in/"
    }
  ],
  'bn': [
    {
      "schemeName": "প্রধানমন্ত্রী কিষাণ সম্মান নিধি (পিএম-কিসান)",
      "description":
          "কিছু বর্জন সাপেক্ষে, সারা দেশে চাষযোগ্য জমি থাকা সমস্ত ভূমিধারী কৃষক পরিবারকে আয় সহায়তা প্রদান করে।",
      "benefits":
          "কৃষকদের ব্যাঙ্ক অ্যাকাউন্টে সরাসরি তিনটি সমান কিস্তিতে প্রতি বছর 6000 টাকা।",
      "eligibility":
          "চাষযোগ্য জমি সহ সমস্ত ভূমিধারী কৃষক পরিবার, আয়কর প্রদানকারী এবং প্রাতিষ্ঠানিক ভূমিধারীদের মতো বর্জন সাপেক্ষে।",
      "website": "https://pmkisan.gov.in/"
    },
    {
      "schemeName": "প্রধানমন্ত্রী ফসল বীমা যোজনা (পিএমএফবিওয়াই)",
      "description":
          "প্রাকৃতিক দুর্যোগের কারণে ক্ষতিগ্রস্ত কৃষকদের ব্যাপক ঝুঁকি বীমা কভারেজ প্রদান করে।",
      "benefits":
          "অনিবার্য প্রাকৃতিক ঝুঁকির কারণে ফসলের ক্ষতির জন্য বীমা কভারেজ।",
      "eligibility":
          "বিজ্ঞপ্তিভুক্ত এলাকায় বিজ্ঞপ্তিভুক্ত ফসল উৎপাদনকারী সকল কৃষক।",
      "website": "https://pmfby.gov.in/"
    },
    {
      "schemeName": "মাটি স্বাস্থ্য কার্ড প্রকল্প",
      "description":
          "কৃষকদের মাটি স্বাস্থ্য কার্ড প্রদান করে, যাতে মাটির পুষ্টির অবস্থা এবং উপযুক্ত সার ব্যবহারের সুপারিশ সম্পর্কে তথ্য থাকে।",
      "benefits":
          "মাটির স্বাস্থ্যের উন্নতি, ইনপুট খরচ হ্রাস এবং ফসলের উৎপাদনশীলতা বৃদ্ধি।",
      "eligibility": "কৃষি জমির মালিক সকল কৃষক।",
      "website": "https://soilhealth.dac.gov.in/"
    },
    {
      "schemeName": "পরম্পরাগত কৃষি বিকাশ যোজনা (পিকেভিওয়াই)",
      "description":
          "কৃষকদের ক্লাস্টার গঠন এবং সক্ষমতা তৈরির মাধ্যমে জৈব চাষকে উৎসাহিত করে।",
      "benefits":
          "জৈব চাষের জন্য আর্থিক সহায়তা, মাটির স্বাস্থ্যের উন্নতি এবং জৈব বাজারে প্রবেশাধিকার।",
      "eligibility": "জৈব চাষ পদ্ধতি গ্রহণকারী কৃষকদের গোষ্ঠী।",
      "website": "https://pgsindia-ncof.gov.in/"
    },
    {
      "schemeName": "কিষাণ ক্রেডিট কার্ড (কেসিসি)",
      "description":
          "কৃষকদের কৃষি উপকরণ এবং অন্যান্য প্রয়োজনের জন্য ঋণের সহজ অ্যাক্সেস প্রদান করে।",
      "benefits": "ছাড়ের সুদের হারে ঋণ, নমনীয় পরিশোধের বিকল্প।",
      "eligibility": "কৃষি এবং সংশ্লিষ্ট কার্যকলাপে নিযুক্ত কৃষক।",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
    },
    {
      "schemeName": "জাতীয় কৃষি বাজার (ই-নাম)",
      "description":
          "একটি প্যান-ইন্ডিয়া ইলেকট্রনিক ট্রেডিং পোর্টাল যা কৃষি পণ্যের জন্য একটি ঐক্যবদ্ধ জাতীয় বাজার তৈরি করতে বিদ্যমান কৃষি উৎপাদন বাজার কমিটি (এপিএমসি) নেটওয়ার্ক করে।",
      "benefits":
          "আরও ভাল মূল্য আবিষ্কার, স্বচ্ছ নিলাম প্রক্রিয়া এবং লেনদেনের খরচ হ্রাস।",
      "eligibility": "ই-নামের সাথে নিবন্ধিত কৃষক এবং ব্যবসায়ী।",
      "website": "https://enam.gov.in/web/"
    },
    {
      "schemeName": "প্রধানমন্ত্রী কৃষি সিঞ্চাই যোজনা (পিএমকেএসওয়াই)",
      "description":
          "খামারে জলের ভৌত অ্যাক্সেস বৃদ্ধি করা এবং নিশ্চিত সেচের অধীনে চাষযোগ্য এলাকা প্রসারিত করা, খামারে জলের ব্যবহার দক্ষতা উন্নত করা, টেকসই জল সংরক্ষণ পদ্ধতি প্রবর্তন করা ইত্যাদির লক্ষ্য।",
      "benefits": "সেচের সুবিধা, জল সংরক্ষণ এবং ফসলের উৎপাদনশীলতার উন্নতি।",
      "eligibility": "কৃষি জমি সহ সকল কৃষক।",
      "website": "https://pmksy.gov.in/"
    },
    {
      "schemeName": "উদ্যানপালনের সমন্বিত উন্নয়নের জন্য মিশন (এমআইডিএইচ)",
      "description":
          "ফল, শাকসবজি, মূল এবং কন্দ ফসল, মাশরুম, মশলা, ফুল, সুগন্ধি গাছপালা, নারকেল, কাজু, বাঁশ এবং মধু সহ উদ্যানপালন খাতের সামগ্রিক বৃদ্ধিকে উৎসাহিত করা।",
      "benefits":
          "উদ্যানপালন উন্নয়ন, উন্নত উৎপাদনশীলতা এবং বাজার অ্যাক্সেসের জন্য আর্থিক সহায়তা।",
      "eligibility": "উদ্যানপালনে নিযুক্ত কৃষক এবং উদ্যোক্তা।",
      "website": "https://midh.gov.in/"
    },
    {
      "schemeName": "রাষ্ট্রীয় কৃষি বিকাশ যোজনা (আরকেভিওয়াই)",
      "description":
          "কৃষি এবং সংশ্লিষ্ট সেক্টরের সামগ্রিক উন্নয়ন নিশ্চিত করে কৃষি খাতে 4% বার্ষিক প্রবৃদ্ধি অর্জন করা।",
      "benefits": "কৃষি উন্নয়ন প্রকল্প এবং অবকাঠামোর জন্য আর্থিক সহায়তা।",
      "eligibility": "রাজ্য সরকার এবং কৃষি প্রতিষ্ঠান।",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
    },
    {
      "schemeName": "জাতীয় খাদ্য সুরক্ষা মিশন (এনএফএসএম)",
      "description":
          "এলাকা সম্প্রসারণ এবং উৎপাদনশীলতা বৃদ্ধির মাধ্যমে ধান, গম, ডাল, মোটা শস্য এবং পুষ্টি শস্যের উৎপাদন বৃদ্ধি করা।",
      "benefits": "খাদ্য উৎপাদন এবং প্রাপ্যতা বৃদ্ধি, কৃষকের আয় বৃদ্ধি।",
      "eligibility": "বিজ্ঞপ্তিভুক্ত ফসল উৎপাদনে নিযুক্ত সকল কৃষক।",
      "website": "https://nfsm.gov.in/"
    }
  ],
  'ur': [
    {
      "schemeName": "پرادھان منتری کسان سمان ندھی (پی ایم-کسان)",
      "description":
          "کچھ اخراجات کے تابع، ملک بھر میں تمام زمیندار کسان خاندانوں کو ان کی قابل کاشت زمین کے ساتھ آمدنی کی مدد فراہم کرتا ہے۔",
      "benefits":
          "کسانوں کے بینک کھاتوں میں براہ راست تین برابر قسطوں میں فی سال 6000 روپے۔",
      "eligibility":
          "قابل کاشت زمین والے تمام زمیندار کسان خاندان، آمدنی ٹیکس دہندگان اور ادارہ جاتی زمینداروں جیسے اخراجات کے تابع۔",
      "website": "https://pmkisan.gov.in/"
    },
    {
      "schemeName": "پرادھان منتری فصل بیمہ یوجنا (پی ایم ایف بی وائی)",
      "description":
          "قدرتی آفات کی وجہ سے ہونے والے نقصانات کے لیے کسانوں کو جامع خطرے کی انشورنس کوریج فراہم کرتا ہے۔",
      "benefits":
          "غیر روک تھام والے قدرتی خطرات کی وجہ سے فصل کے نقصان کے لیے انشورنس کوریج۔",
      "eligibility": "مطلع شدہ علاقوں میں مطلع شدہ فصلیں اگانے والے تمام کسان۔",
      "website": "https://pmfby.gov.in/"
    },
    {
      "schemeName": "مٹی صحت کارڈ اسکیم",
      "description":
          "کسانوں کو مٹی صحت کارڈ فراہم کرتا ہے، جس میں مٹی کے غذائی اجزاء کی حیثیت اور مناسب کھاد کے استعمال کے لیے سفارشات کے بارے میں معلومات ہوتی ہیں۔",
      "benefits":
          "مٹی کی صحت میں بہتری، ان پٹ لاگت میں کمی اور فصل کی پیداواری صلاحیت میں اضافہ۔",
      "eligibility": "زرعی زمین کے مالک تمام کسان۔",
      "website": "https://soilhealth.dac.gov.in/"
    },
    {
      "schemeName": "پرامپراگت کرشی وکاس یوجنا (پی کے وی وائی)",
      "description":
          "کسانوں کے کلسٹروں کی تشکیل اور صلاحیت سازی کے ذریعے نامیاتی کاشتکاری کو فروغ دیتا ہے۔",
      "benefits":
          "نامیاتی کاشتکاری کے لیے مالی امداد، مٹی کی صحت میں بہتری اور نامیاتی منڈیوں تک رسائی۔",
      "eligibility":
          "نامیاتی کاشتکاری کے طریقوں کو اپنانے والے کسانوں کے گروہ۔",
      "website": "https://pgsindia-ncof.gov.in/"
    },
    {
      "schemeName": "کسان کریڈٹ کارڈ (کے سی سی)",
      "description":
          "کسانوں کو زرعی ان پٹ اور دیگر ضروریات کے لیے کریڈٹ تک آسان رسائی فراہم کرتا ہے۔",
      "benefits": "رعایتی شرح سود پر کریڈٹ، لچکدار ادائیگی کے اختیارات۔",
      "eligibility": "زراعت اور متعلقہ سرگرمیوں میں مصروف کسان۔",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
    },
    {
      "schemeName": "قومی زرعی منڈی (ای-نام)",
      "description":
          "ایک پین-انڈیا الیکٹرانک ٹریڈنگ پورٹل جو زرعی اجناس کے لیے ایک متحد قومی منڈی بنانے کے لیے موجودہ زرعی پیداوار مارکیٹ کمیٹیوں (اے پی ایم سی) کو نیٹ ورک کرتا ہے۔",
      "benefits":
          "بہتر قیمت دریافت، شفاف نیلامی کا عمل اور لین دین کی کم لاگت۔",
      "eligibility": "ای-نام کے ساتھ رجسٹرڈ کسان اور تاجر۔",
      "website": "https://enam.gov.in/web/"
    },
    {
      "schemeName": "پرادھان منتری کرشی سینچائی یوجنا (پی ایم کے ایس وائی)",
      "description":
          "فارم پر پانی کی جسمانی رسائی کو بڑھانا اور یقینی آبپاشی کے تحت قابل کاشت رقبہ کو بڑھانا، فارم پر پانی کے استعمال کی کارکردگی کو بہتر بنانا، پائیدار پانی کے تحفظ کے طریقوں کو متعارف کرانا وغیرہ کا مقصد ہے۔",
      "benefits":
          "آبپاشی کی سہولیات میں بہتری، پانی کا تحفظ اور فصل کی پیداواری صلاحیت میں اضافہ۔",
      "eligibility": "زرعی زمین والے تمام کسان۔",
      "website": "https://pmksy.gov.in/"
    },
    {
      "schemeName": "باغبانی کی مربوط ترقی کے لیے مشن (ایم آئی ڈی ایچ)",
      "description":
          "پھل، سبزیاں، جڑ اور تند کی فصلیں، مشروم، مصالحے، پھول، خوشبودار پودے، ناریل، کاجو، بانس اور شہد سمیت باغبانی کے شعبے کی مجموعی ترقی کو فروغ دینا ہے۔",
      "benefits":
          "باغبانی کی ترقی، بہتر پیداواری صلاحیت اور مارکیٹ تک رسائی کے لیے مالی امداد۔",
      "eligibility": "باغبانی میں مصروف کسان اور کاروباری افراد۔",
      "website": "https://midh.gov.in/"
    },
    {
      "schemeName": "راشٹریہ کرشی وکاس یوجنا (آر کے وی وائی)",
      "description":
          "زراعت اور متعلقہ شعبوں کی مجموعی ترقی کو یقینی بنا کر زرعی شعبے میں 4 فیصد سالانہ ترقی حاصل کرنا ہے۔",
      "benefits": "زرعی ترقی کے منصوبوں اور بنیادی ڈھانچے کے لیے مالی امداد۔",
      "eligibility": "ریاستی حکومتیں اور زرعی ادارے",
    }
  ],
  'ta': [
    {
      "schemeName": "பிரதான் மந்திரி கிசான் சம்மான் நிதி (பிஎம்-கிசான்)",
      "description":
          "சில விலக்குகளுக்கு உட்பட்டு, நாடு முழுவதும் உள்ள அனைத்து நில உரிமையாளர் விவசாயக் குடும்பங்களுக்கும் பயிர் செய்யக்கூடிய நிலத்துடன் வருமான ஆதரவை வழங்குகிறது.",
      "benefits":
          "விவசாயிகளின் வங்கிக் கணக்குகளுக்கு நேரடியாக மூன்று சம தவணைகளில் ஆண்டுக்கு ரூ.6000.",
      "eligibility":
          "பயிர் செய்யக்கூடிய நிலம் உள்ள அனைத்து நில உரிமையாளர் விவசாயக் குடும்பங்கள், வருமான வரி செலுத்துவோர் மற்றும் நிறுவன நில உரிமையாளர்கள் போன்ற விலக்குகளுக்கு உட்பட்டு.",
      "website": "https://pmkisan.gov.in/"
    },
    {
      "schemeName": "பிரதான் மந்திரி ஃபசல் பீமா யோஜனா (பிஎம்எஃப்பிஒய்)",
      "description":
          "இயற்கை பேரழிவுகள் காரணமாக ஏற்படும் இழப்புகளுக்கு விவசாயிகளுக்கு விரிவான இடர் காப்பீட்டு பாதுகாப்பை வழங்குகிறது.",
      "benefits":
          "தடுக்க முடியாத இயற்கை அபாயங்கள் காரணமாக பயிர் இழப்புக்கான காப்பீட்டு பாதுகாப்பு.",
      "eligibility":
          "அறிவிக்கப்பட்ட பகுதிகளில் அறிவிக்கப்பட்ட பயிர்களை பயிரிடும் அனைத்து விவசாயிகள்.",
      "website": "https://pmfby.gov.in/"
    },
    {
      "schemeName": "மண் சுகாதார அட்டை திட்டம்",
      "description":
          "விவசாயிகளுக்கு மண் ஊட்டச்சத்து நிலை மற்றும் பொருத்தமான உர பயன்பாட்டிற்கான பரிந்துரைகள் பற்றிய தகவல்களைக் கொண்ட மண் சுகாதார அட்டைகளை வழங்குகிறது.",
      "benefits":
          "மேம்பட்ட மண் ஆரோக்கியம், குறைந்த உள்ளீட்டு செலவுகள் மற்றும் அதிகரித்த பயிர் உற்பத்தித்திறன்.",
      "eligibility": "விவசாய நிலம் வைத்திருக்கும் அனைத்து விவசாயிகள்.",
      "website": "https://soilhealth.dac.gov.in/"
    },
    {
      "schemeName": "பரம்பரகத் கிருஷி விகாஸ் யோஜனா (பி.கே.வி.ஒய்)",
      "description":
          "விவசாயிகளின் குழு உருவாக்கம் மற்றும் திறன் மேம்பாடு மூலம் கரிம விவசாயத்தை ஊக்குவிக்கிறது.",
      "benefits":
          "கரிம விவசாயத்திற்கான நிதி உதவி, மேம்பட்ட மண் ஆரோக்கியம் மற்றும் கரிம சந்தைகளுக்கான அணுகல்.",
      "eligibility": "கரிம விவசாய முறைகளை பின்பற்றும் விவசாயிகள் குழுக்கள்.",
      "website": "https://pgsindia-ncof.gov.in/"
    },
    {
      "schemeName": "கிசான் கடன் அட்டை (கேசிசி)",
      "description":
          "விவசாய உள்ளீடுகள் மற்றும் பிற தேவைகளுக்கான கடனை விவசாயிகள் எளிதாக அணுகுவதை வழங்குகிறது.",
      "benefits":
          "சலுகை வட்டி விகிதங்களில் கடன், நெகிழ்வான திருப்பிச் செலுத்தும் விருப்பங்கள்.",
      "eligibility":
          "விவசாயம் மற்றும் அதனுடன் தொடர்புடைய நடவடிக்கைகளில் ஈடுபட்டுள்ள விவசாயிகள்.",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
    },
    {
      "schemeName": "தேசிய விவசாய சந்தை (இ-நாம்)",
      "description":
          "விவசாயப் பொருட்களுக்கு ஒரு ஒருங்கிணைந்த தேசிய சந்தையை உருவாக்க தற்போதுள்ள விவசாய உற்பத்தி சந்தைக் குழுக்களை (ஏபிஎம்சி) இணைக்கும் ஒரு பான்-இந்தியா மின்னணு வர்த்தக போர்டல்.",
      "benefits":
          "சிறந்த விலை கண்டறிதல், வெளிப்படையான ஏல செயல்முறை மற்றும் குறைந்த பரிவர்த்தனை செலவுகள்.",
      "eligibility": "இ-நாமில் பதிவு செய்த விவசாயிகள் மற்றும் வணிகர்கள்.",
      "website": "https://enam.gov.in/web/"
    },
    {
      "schemeName": "பிரதான் மந்திரி கிருஷி சிஞ்சாயி யோஜனா (பி.எம்.கே.எஸ்.ஒய்)",
      "description":
          "பண்ணையில் நீரின் உடல் அணுகலை மேம்படுத்துதல் மற்றும் உறுதியான நீர்ப்பாசனத்தின் கீழ் பயிரிடக்கூடிய பரப்பளவை விரிவுபடுத்துதல், பண்ணை நீர் பயன்பாட்டு திறனை மேம்படுத்துதல், நிலையான நீர் பாதுகாப்பு நடைமுறைகளை அறிமுகப்படுத்துதல் போன்றவற்றை நோக்கமாகக் கொண்டுள்ளது.",
      "benefits":
          "மேம்பட்ட நீர்ப்பாசன வசதிகள், நீர் பாதுகாப்பு மற்றும் மேம்பட்ட பயிர் உற்பத்தித்திறன்.",
      "eligibility": "விவசாய நிலம் உள்ள அனைத்து விவசாயிகள்.",
      "website": "https://pmksy.gov.in/"
    },
    {
      "schemeName": "தோட்டக்கலை ஒருங்கிணைந்த மேம்பாட்டுக்கான மிஷன் (எம்ஐடிஎச்)",
      "description":
          "பழங்கள், காய்கறிகள், வேர் மற்றும் கிழங்கு பயிர்கள், காளான்கள், மசாலாப் பொருட்கள், பூக்கள், நறுமண தாவரங்கள், தேங்காய், முந்திரி, மூங்கில் மற்றும் தேன் உள்ளிட்ட தோட்டக்கலை துறையின் முழுமையான வளர்ச்சியை ஊக்குவிப்பதை நோக்கமாகக் கொண்டுள்ளது.",
      "benefits":
          "தோட்டக்கலை மேம்பாடு, மேம்பட்ட உற்பத்தித்திறன் மற்றும் சந்தை அணுகலுக்கான நிதி உதவி.",
      "eligibility":
          "தோட்டக்கலையில் ஈடுபட்டுள்ள விவசாயிகள் மற்றும் தொழில் முனைவோர்.",
      "website": "https://midh.gov.in/"
    },
    {
      "schemeName": "ராஷ்ட்ரிய கிருஷி விகாஸ் யோஜனா (ஆர்.கே.வி.ஒய்)",
      "description":
          "விவசாயம் மற்றும் அதனுடன் தொடர்புடைய துறைகளின் முழுமையான வளர்ச்சியை உறுதி செய்வதன் மூலம் விவசாயத் துறையில் 4% ஆண்டு வளர்ச்சியை அடைவதை நோக்கமாகக் கொண்டுள்ளது.",
      "benefits":
          "விவசாய மேம்பாட்டுத் திட்டங்கள் மற்றும் உள்கட்டமைப்புக்கான நிதி உதவி.",
      "eligibility": "மாநில அரசுகள் மற்றும் விவசாய நிறுவனங்கள்.",
      "website":
          "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
    },
    {
      "schemeName": "தேசிய உணவு பாதுகாப்பு மிஷன் (என்.எஃப்.எஸ்.எம்)",
      "description":
          "பகுதி விரிவாக்கம் மற்றும் உற்பத்தித்திறன் மேம்பாடு மூலம் அரிசி, கோதுமை, பருப்பு வகைகள், பருப்பு தானியங்கள் மற்றும் ஊட்டச்சத்து தானியங்களின் உற்பத்தியை அதிகரிப்பதை நோக்கமாகக் கொண்டுள்ளது.",
      "benefits":
          "அதிகரித்த உணவு உற்பத்தி மற்றும் கிடைக்கும் தன்மை, மேம்பட்ட விவசாயி வருமானம்.",
      "eligibility":
          "அறிவிக்கப்பட்ட பயிர்களை உற்பத்தி செய்யும் அனைத்து விவசாயிகள்.",
      "website": "https://nfsm.gov.in/"
    }
  ],
};

class AgricultureSchemesPage extends StatefulWidget {
  const AgricultureSchemesPage({Key? key}) : super(key: key);

  @override
  _AgricultureSchemesPageState createState() => _AgricultureSchemesPageState();
}

class _AgricultureSchemesPageState extends State<AgricultureSchemesPage> {
  String _languageCode = 'en'; // Default language
  List<Map<String, dynamic>> _schemes = [];
  AppLocalizations? localizations;

  @override
  void initState() {
    super.initState();
    _loadLanguageAndSchemes();
    _initLocalization();
  }

  Future<void> _initLocalization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language') ?? 'en';
    setState(() {
      localizations = AppLocalizations(Locale(languageCode));
    });
  }

  Future<void> _loadLanguageAndSchemes() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode =
        prefs.getString('language') ?? 'en'; // Get stored language or default
    _schemes = (agricultureSchemesTranslations[_languageCode] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    setState(() {}); // Update the UI
  }

  @override
  Widget build(BuildContext context) {
    if (_schemes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture Schemes'),
      ),
      body: ListView.builder(
        itemCount: _schemes.length,
        itemBuilder: (context, index) {
          final scheme = _schemes[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme['schemeName']
                        [localizations?.locale.languageCode ?? 'en'],
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    scheme['description']
                        [localizations?.locale.languageCode ?? 'en'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Benefits: ${scheme['benefits'][localizations?.locale.languageCode ?? 'en']}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Eligibility: ${scheme['eligibility'][localizations?.locale.languageCode ?? 'en']}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 8.0),
                  InkWell(
                    onTap: () async {
                      final url = scheme['website'] as String?;
                      if (url != null && await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Could not launch website')),
                        );
                      }
                    },
                    child: Text(
                      'Website: ${scheme['website'] as String? ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Agriculture Schemes App',
      home: AgricultureSchemesPage(),
    );
  }
}
