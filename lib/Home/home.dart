import 'dart:developer';

import 'package:agriculture/Courses/courses_page.dart';
import 'package:agriculture/Disease/Disease_detection.dart';
import 'package:agriculture/Home/Iot_sensor_data.dart';
import 'package:agriculture/Home/Scheduler.dart';
import 'package:agriculture/Home/SensorData.dart';
import 'package:agriculture/Multilanguage/Applocal.dart';
import 'package:agriculture/Settings.dart';
import 'package:agriculture/about.dart';
import 'package:agriculture/buisness_market/b2b.dart';
import 'package:agriculture/course/Course.dart';
import 'package:agriculture/weatherforecast.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String agricultureSchemesJson = '''
[
  {
  "imageUrl": "https://bachatyojana.in/wp-content/uploads/2023/12/PM-Kisan-Samman-Nidhi-Yojana.png",
    "schemeName": "Pradhan Mantri Kisan Samman Nidhi (PM-KISAN)",
    "description": "Provides income support to all landholding farmer families across the country, with cultivable landholding, subject to certain exclusions.",
    "benefits": "Rs. 6000 per year, in three equal installments, directly into the farmers' bank accounts.",
    "eligibility": "All landholding farmer families with cultivable land, subject to exclusions like income tax payers and institutional landholders.",
    "website": "https://pmkisan.gov.in/"
  },
  {
  "imageUrl" : "https://www.mygov.in/sites/all/themes/mygov/images/pmfby/pmfby-banner.jpg",
    "schemeName": "Pradhan Mantri Fasal Bima Yojana (PMFBY)",
    "description": "Provides comprehensive risk insurance coverage to farmers for losses suffered due to natural calamities.",
    "benefits": "Insurance coverage for crop loss due to non-preventable natural risks.",
    "eligibility": "All farmers growing notified crops in notified areas.",
    "website": "https://pmfby.gov.in/"
  },
  {
  "imageUrl":"https://www.india.gov.in/sites/upload_files/npi/files/spotlights/soil-health-card-inner.jpg",
    "schemeName": "Soil Health Card Scheme",
    "description": "Provides soil health cards to farmers, containing information about soil nutrient status and recommendations for appropriate fertilizer use.",
    "benefits": "Improved soil health, reduced input costs, and increased crop productivity.",
    "eligibility": "All farmers owning agricultural land.",
    "website": "https://soilhealth.dac.gov.in/"
  },
  {
  "imageUrl" : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeWUjrg9truLF_cuX3eM43NF4hDnXzFNApqFuvSdfoeaW6DBohGm78YVtp5SBEHPcGp5Y&usqp=CAU",
    "schemeName": "Paramparagat Krishi Vikas Yojana (PKVY)",
    "description": "Promotes organic farming through cluster formation and capacity building of farmers.",
    "benefits": "Financial assistance for organic farming, improved soil health, and access to organic markets.",
    "eligibility": "Groups of farmers adopting organic farming practices.",
    "website": "https://pgsindia-ncof.gov.in/"
  },
  {
  "imageUrl" : "https://resize.indiatvnews.com/en/resize/newbucket/1200_-/2023/01/kisan-credit-card-big-1604458302-1674206643.jpg",
    "schemeName": "Kisan Credit Card (KCC)",
    "description": "Provides farmers with easy access to credit for agricultural inputs and other needs.",
    "benefits": "Credit at concessional interest rates, flexible repayment options.",
    "eligibility": "Farmers engaged in agriculture and allied activities.",
    "website": "https://agricoop.nic.in/en/programmeschemes/kisan-credit-card-kcc"
  },
  {
  "imageUrl" : "https://enam.gov.in/web/Slider_gallary/1/Onion-Trade.png",
    "schemeName": "National Agriculture Market (eNAM)",
    "description": "A pan-India electronic trading portal that networks the existing Agricultural Produce Market Committees (APMCs) to create a unified national market for agricultural commodities.",
    "benefits": "Better price discovery, transparent auction process, and reduced transaction costs.",
    "eligibility": "Farmers and traders registered with eNAM.",
    "website": "https://enam.gov.in/web/"
  },
  {
  "imageUrl" : "https://www.india.gov.in/sites/upload_files/npi/files/spotlights/pmksy.jpg",
    "schemeName": "Pradhan Mantri Krishi Sinchayee Yojana (PMKSY)",
    "description": "Aims to enhance physical access of water on farm and expand cultivable area under assured irrigation, improve on farm water use efficiency, introduce sustainable water conservation practices etc.",
    "benefits": "Improved irrigation facilities, water conservation, and enhanced crop productivity.",
    "eligibility": "All farmers with agricultural land.",
    "website": "https://pmksy.gov.in/"
  },
  {
  "imageUrl" : "https://www.insightsonindia.com/wp-content/uploads/2024/10/midmp-2.jpg",
    "schemeName": "Mission for Integrated Development of Horticulture (MIDH)",
    "description": "Aims to promote holistic growth of the horticulture sector, including fruits, vegetables, root and tuber crops, mushrooms, spices, flowers, aromatic plants, coconut, cashew, bamboo and honey.",
    "benefits": "Financial assistance for horticulture development, improved productivity, and market access.",
    "eligibility": "Farmers and entrepreneurs engaged in horticulture.",
    "website": "https://midh.gov.in/"
  },
  {
  "imageUrl" : "https://sribhumi.assam.gov.in/sites/default/files/styles/scheme_cover_image_for_details_page_710x402_/public/public_utility/image1.jpg",
    "schemeName": "Rashtriya Krishi Vikas Yojana (RKVY)",
    "description": "Aims to achieve 4% annual growth in the agriculture sector by ensuring holistic development of agriculture and allied sectors.",
    "benefits": "Financial assistance for agricultural development projects and infrastructure.",
    "eligibility": "State governments and agricultural institutions.",
    "website": "https://agricoop.nic.in/en/programmeschemes/rashtriya-krishi-vikas-yojana-rkvys"
  },
  {
  "imageUrl" : "https://lms.chanakyamandal.org/wp-content/uploads/2021/03/National-Food-Security-Mission.png",
    "schemeName": "National Food Security Mission (NFSM)",
    "description": "Aims to increase production of rice, wheat, pulses, coarse cereals and nutri-cereals through area expansion and productivity enhancement.",
    "benefits": "Increased food production and availability, improved farmer income.",
    "eligibility": "All farmers engaged in the production of notified crops.",
    "website": "https://nfsm.gov.in/"
  }
]
''';

// Replace with your OpenWeatherMap API key
String weatherApiKey = '3e18874392caba4815ba03ce546fc1e9';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _showNotification(String title, String body) async {
  try {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'weather_alert_channel', // id
      'Weather Alerts', // title
      description: 'Weather alerts for farmers', // description
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  } catch (e) {
    print('Error showing notification: $e');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.initialTask});

  final List<Map<String, dynamic>> initialTask;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  double _soilMoisture = 65.0;
  double _temperature = 28.0;
  double _humidity = 70.0;
  String _weatherDescription = '';
  String _weatherdata = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _taskDescription = '';
  String _username = '';
  String _name = '';
  String _email = '';
  List<Map<String, dynamic>> _scheduledTasks = [];

  Map<String, dynamic> weatherData = {};

  String _languageCode = 'en';

  Future<void> _loadLanguage() async {
    _languageCode = await getLanguageCode();
    setState(() {}); // Rebuild the widget when language code is fetched.
  }

  Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // If the URL can't be launched, show an error (e.g., a SnackBar)
      throw Exception('Could not launch $uri');
    }
  }

  List<dynamic> schemes = [];
  Future<void> _loadSchemes() async {
    print(agricultureSchemesJson);
    setState(() {
      schemes = json.decode(agricultureSchemesJson);
    });
  }

  Future<void> _loadTasks() async {
    final taskCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('scheduledTasks');
    final taskDocs =
        taskCollection.get().then((querySnapshot) => querySnapshot.docs);

    taskDocs.then((docs) {
      if (docs.isNotEmpty) {
        print(docs.map((e) => e.data()).toList());
        setState(() {
          _scheduledTasks = docs.map((doc) => doc.data()).toList();
        });
      } else {
        print("No tasks found or failed to update.");
      }
    });

    if (_scheduledTasks != null && _scheduledTasks.isNotEmpty) {
      print("tasks : $_scheduledTasks");
    } else {
      print("No tasks found or failed to update.");
    }
  }

  Future<void> _loadData() async {
    try {
      final userCollection = FirebaseFirestore.instance.collection('profiles');
      final userID = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = userCollection.doc(userID);
      print(userDoc);
      final userData = userDoc.get().then((doc) => doc.data());

      userData.then((data) {
        setState(() {
          _username = data?['username'] ?? '';
          _name = data?['name'] ?? '';
          _email = data?['email'] ?? '';
        });
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    CropDetailsPage(),
    DiseaseDetectionPage(),
    MarketplaceScreen(),
    CoursesPage()
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchWeatherData();
    _startWeatherCheck();
    _loadSchemes();
    _loadData();
    _loadTasks();
  }

  Future<void> _fetchWeatherData() async {
    // Keep track of whether we could get a location
    bool locationFetched = false;
    double? lat;
    double? lon;

    try {
      // --- Location Services Check (Keep this) ---
      Location location = Location();
      bool serviceEnabled;
      PermissionStatus
          permissionGranted; // We still need to check the status *from the location package's perspective* before getting location

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        // Ask user to enable location services if they are off
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          // Optionally show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Please enable location services for weather updates.')),
          );
          // Try fetching from cache or default if services remain disabled
          // return; // Or proceed to try cache
        }
      }

      // --- Permission Check (Modify this part) ---
      // Instead of requesting again, just check if granted by the earlier handler
      // We rely on PermissionHandlerWrapper having already requested if needed.
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied ||
          permissionGranted == PermissionStatus.deniedForever) {
        print('Location permission is denied. Cannot fetch live weather.');
        // Optionally show a message or use a default location/cache
        // ScaffoldMessenger.of(context).showSnackBar(
        //    const SnackBar(content: Text('Location permission denied. Showing cached weather or default.')),
        //  );
        // Proceed to try fetching from cache below, DO NOT request again.
      } else {
        // --- Get Location (Only if services enabled and permission granted) ---
        try {
          LocationData locationData = await location.getLocation();
          lat = locationData.latitude;
          lon = locationData.longitude;
          locationFetched = true;
          print('Location fetched: Lat=$lat, Lon=$lon');
        } catch (e) {
          print('Error getting location even with permission: $e');
          // Handle cases like GPS signal issues, etc.
          // Proceed to try fetching from cache below.
        }
      }

      // --- Fetch Weather Data ---
      // Try fetching from API only if location was successfully obtained
      if (locationFetched && lat != null && lon != null) {
        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$weatherApiKey')); // Added units=metric

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Weather data fetched from API.');
          if (mounted) {
            // Check if widget is still mounted before calling setState
            setState(() {
              weatherData = data;
              _weatherDescription = weatherData['weather'][0]['description'];
              _weatherdata = weatherData['name']; // City name
            });
          }
          // Save to cache
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('weatherData', json.encode(data));
          await prefs.setDouble('lastLat', lat!); // Cache coordinates too
          await prefs.setDouble('lastLon', lon!);
          print('Weather data saved to cache.');
          return; // Exit after successful API fetch
        } else {
          print(
              'Failed to fetch weather data from API: ${response.statusCode}');
          // Fall through to try cache if API fails
        }
      }

      // --- Fallback: Try loading from Cache if API fetch wasn't possible/successful ---
      print('Attempting to load weather data from cache...');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedWeatherData = prefs.getString('weatherData') ?? '';
      if (storedWeatherData.isNotEmpty) {
        final cachedData = json.decode(storedWeatherData);
        print('Weather data loaded from cache.');
        if (mounted) {
          setState(() {
            weatherData = cachedData;
            _weatherDescription = weatherData['weather'][0]['description'];
            _weatherdata = weatherData['name']; // City name
          });
        }
      } else {
        print('No cached weather data found.');
        // Handle case where there's no location and no cache (e.g., show default message)
        if (mounted) {
          setState(() {
            _weatherDescription = 'N/A';
            _weatherdata = 'Unknown Location';
          });
        }
      }
    } catch (e) {
      print('Error in _fetchWeatherData: $e');
      // Attempt to load from cache even if there was an error earlier
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String storedWeatherData = prefs.getString('weatherData') ?? '';
        if (storedWeatherData.isNotEmpty) {
          final cachedData = json.decode(storedWeatherData);
          print('Weather data loaded from cache after error.');
          if (mounted) {
            setState(() {
              weatherData = cachedData;
              _weatherDescription = weatherData['weather'][0]['description'];
              _weatherdata = weatherData['name']; // City name
            });
          }
        } else {
          print('No cached weather data found after error.');
          if (mounted) {
            setState(() {
              _weatherDescription = 'Error';
              _weatherdata = 'N/A';
            });
          }
        }
      } catch (cacheError) {
        print(
            'Error loading weather from cache after initial error: $cacheError');
        if (mounted) {
          setState(() {
            _weatherDescription = 'Error';
            _weatherdata = 'N/A';
          });
        }
      }
    }
  }

  void _startWeatherCheck() {
    Future.delayed(const Duration(minutes: 5), () {
      _fetchWeatherData();
      if (_weatherDescription.toLowerCase().contains('scattered clouds') ||
          _weatherDescription.toLowerCase().contains('haze')) {
        _showNotification('Weather Alert',
            'Cloudy or hazy conditions detected. Take necessary precautions.');
      }
      _startWeatherCheck(); // Schedule the next check
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Locale myLocale = Locale(_languageCode);
    AppLocalizations localizations = AppLocalizations(myLocale);

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/u/43668321?v=4'),
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Colors.lightBlue.shade400,
                Colors.blue.shade700
              ])),
            ),
            ListTile(
              title: const Text('Explore Learning'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CoursePage()));
              },
            ),
            ListTile(
              title: const Text('Weather Forecast'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WeatherForecastWidget(
                              apiKey: weatherApiKey,
                            )));
              },
            ),
            ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingPage(),
                      ));
                }),
            ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                })
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('AgriIot'),
        titleSpacing: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey[100],
          fontFamily: 'Poppins',
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Builder(
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: Icon(Icons.menu, color: Colors.grey[800]),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightBlue[400]!,
        buttonBackgroundColor: Colors.blue[700]!,
        color: Colors.lightBlue[100]!,
        height: 70,
        animationCurve: Curves.easeIn,
        animationDuration: Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? Colors.white : null,
            ),
            label: localizations.home,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.crop,
              color: _selectedIndex == 1 ? Colors.white : null,
            ),
            label: localizations.disease,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.store,
              color: _selectedIndex == 2 ? Colors.white : null,
            ),
            label: localizations.marketplace,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.menu_book_outlined,
              color: _selectedIndex == 3 ? Colors.white : null,
            ),
            label: localizations.course,
          ),
        ],
      ),
    );
  }

  Widget buildCropDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
      ),
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WeatherForecastWidget(apiKey: weatherApiKey)),
              );
            },
            child: Hero(
              tag: 'weather',
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.lightBlue.shade200, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.cloud, color: Colors.blue, size: 50),
                        SizedBox(width: 10),
                        Text('Weather Report',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Icon(Icons.thermostat, color: Colors.red),
                            Text('Temperature'),
                            Text(
                                '${weatherData['main']?['temp'] != null ? '${(weatherData['main']['temp'] / 10 as double).toStringAsFixed(0)}' : "25"} C',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins')),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(Icons.water, color: Colors.blue),
                            Text('Humidity'),
                            Text(
                                '${weatherData['main']?['humidity'] ?? "8 "} %',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins')),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Icon(Icons.air, color: Colors.grey),
                            Text('Wind Speed'),
                            Text('${weatherData['wind']?['speed'] ?? "2 "} m/s',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins')),
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.all(12.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade300, Colors.green.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Row(
                        // Using const is fine here as children are const
                        children: <Widget>[
                          Icon(Icons.timer, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            'Irrigation Scheduler',
                            style: TextStyle(
                              color: Colors
                                  .white, // Note: white on potentially non-white background?
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor:
                              Colors.white, // Ensure text color is visible
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SchedulerPage()),
                          );
                        },
                        child: const Text('Add Schedule'),
                      ),
                      const Divider(height: 20, thickness: 1),
                      if (_scheduledTasks.isEmpty)
                        Text(
                          'No scheduled tasks available.', // More accurate text
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _scheduledTasks.map((task) {
                              // Add null check for the task map itself, although map() usually handles non-null lists
                              // Add null checks for the keys within the map
                              final description =
                                  task['description'] as String? ??
                                      'No Description';
                              final dateString = task['date'] as String?;
                              final timeString = task['time'] as String? ??
                                  'No Time'; // Treat time as String

                              // Safely parse date and format
                              String formattedDate = 'Invalid Date';
                              if (dateString != null) {
                                try {
                                  final dateTime = DateTime.parse(dateString);
                                  formattedDate = DateFormat('dd MMM yyyy')
                                      .format(
                                          dateTime); // Use a more common format
                                } catch (e) {
                                  print('Error parsing date "$dateString": $e');
                                  formattedDate =
                                      'Parse Error'; // Indicate parsing failed
                                }
                              }

                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.green.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.greenAccent.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Stack(
                                  // Use Stack to position delete button independently
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0).copyWith(
                                          right:
                                              40), // Add padding for delete button
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize
                                            .min, // Prevent column from taking max height
                                        children: [
                                          // Display description safely, truncated if needed
                                          Text(
                                            description.length > 10
                                                ? '${description.substring(0, 10)}...'
                                                : description,
                                            textAlign: TextAlign.left,
                                            softWrap: true,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins'),
                                          ),
                                          // Display date safely
                                          Text(
                                            formattedDate,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          // Display time safely
                                          Text(
                                            timeString,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Position the delete button
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0, // Stretch button vertically
                                      child: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors
                                                .redAccent), // Give delete icon a color
                                        onPressed: () async {
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          final tasksJson =
                                              prefs.getString('scheduledTasks');
                                          // Safely decode and filter tasks
                                          if (tasksJson != null) {
                                            try {
                                              final List<dynamic> tasksList =
                                                  json.decode(tasksJson);
                                              // Filter based on a unique identifier if possible,
                                              // or fallback to description (be cautious with duplicates)
                                              final updatedTasks =
                                                  tasksList.where((element) {
                                                // Assuming description is unique enough for deletion here.
                                                // A unique ID in the task map would be better.
                                                return (element is Map<String,
                                                        dynamic>) &&
                                                    element['description'] !=
                                                        description;
                                              }).toList(); // Convert to List<dynamic> first

                                              // Cast to the expected type for setState and encoding
                                              final updatedTasksTyped = List<
                                                      Map<String,
                                                          dynamic>>.from(
                                                  updatedTasks.cast<
                                                      Map<String, dynamic>>());

                                              await prefs.setString(
                                                  'scheduledTasks',
                                                  json.encode(
                                                      updatedTasksTyped));
                                              setState(() {
                                                _scheduledTasks =
                                                    updatedTasksTyped;
                                              });
                                            } catch (e) {
                                              print(
                                                  'Error decoding or filtering tasks: $e');
                                              // Handle the error, e.g., show a message to the user
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Error deleting task.')),
                                              );
                                            }
                                          } else {
                                            // Handle case where tasksJson is null (shouldn't happen if list wasn't empty, but safe)
                                            setState(() {
                                              _scheduledTasks =
                                                  []; // Clear list if stored data is missing
                                            });
                                          }
                                        },
                                        // alignment: Alignment.centerRight, // alignment on IconButton is for the icon itself, not positioning
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text('Soil Data',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Poppins')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SensorDataCharts()),
                          );
                        },
                        child: const Text('View Data',
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                decoration: TextDecoration.underline)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[400]!,
                              Colors.blue[300]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue[200]!,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '20%',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Soil Humidity',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red[400]!,
                                Colors.red[300]!,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red[200]!,
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              )
                            ]),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '30%',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Soil Moisture',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 10),
          if (schemes.isNotEmpty)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Agriculture Schemes",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schemes.length,
                  itemBuilder: (context, index) {
                    final scheme = schemes[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 15.0, right: 15.0, bottom: 15.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.grey.shade100,
                                  Colors.grey.shade200,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue[200]!,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(0),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10.0),
                                    bottomRight: Radius.circular(10.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  scheme['imageUrl'] != null
                                      ? Image.network(scheme['imageUrl']!,
                                          width: double.infinity, height: 150)
                                      : Container(
                                          width: double.infinity,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10.0),
                                                    topRight:
                                                        Radius.circular(10.0)),
                                            color: Colors.blueGrey[100],
                                          ),
                                        ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[600],
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        )),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            scheme['schemeName'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            scheme['description'],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'Benefits: ${scheme['benefits']}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'Eligibility: ${scheme['eligibility']}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'Website: ${scheme['website']}',
                                            style: TextStyle(
                                                color: Colors.purple.shade100,
                                                fontFamily: 'Poppins'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildIrrigationScheduler() {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.timer, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    'Irrigation Scheduler',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Irrigation Schedule:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Every 3 days, 2 times a day, 5 minutes per session.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CropDetailsPage extends StatelessWidget {
  const CropDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final state = context.findAncestorStateOfType<_HomePageState>()!;
      return state.buildCropDetails();
    });
  }
}

class AgricultureEducationPage extends StatelessWidget {
  const AgricultureEducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Agriculture Education',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          const Text('Tips for Small Scale Farmers:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 10),
          const Text('- Use organic fertilizers to improve soil health.\n'
              '- Practice crop rotation to prevent soil depletion.\n'
              '- Implement water conservation techniques.\n'
              '- Choose drought-resistant crop varieties.\n'
              '- Learn about integrated pest management.\n'
              '- Utilize local resources for farming inputs.\n'
              '- Join farmer cooperatives for better market access.\n'
              '- Seek advice from agricultural extension services.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement navigation to more detailed educational content
            },
            child: const Text('Learn More'),
          ),
        ],
      ),
    );
  }
}

/*******  69a5570b-7ee5-4b8d-90d5-89c84fe3d227  *******/

