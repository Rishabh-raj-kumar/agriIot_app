// home_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer'
    as dev; // Use alias to avoid conflict if using logging package
import 'dart:math';

import 'package:agriculture/Disease/crop_monitoring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:google_fonts/google_fonts.dart'; // Already set globally in theme
import 'package:url_launcher/url_launcher.dart';

// Import your other pages (ensure paths are correct)
// --- Adjust these imports based on your actual project structure ---
import 'package:agriculture/Courses/courses_page.dart'; // [cite: 4]
import 'package:agriculture/Disease/Disease_detection.dart'; // [cite: 5]
// import 'package:agriculture/Home/Iot_sensor_data.dart';
import 'package:agriculture/Home/Scheduler.dart'; // [cite: 5]
import 'package:agriculture/Home/SensorData.dart'; // [cite: 5]
import 'package:agriculture/Multilanguage/Applocal.dart'; // [cite: 5]
import 'package:agriculture/Settings.dart'; // [cite: 5]
import 'package:agriculture/about.dart'; // [cite: 5]
import 'package:agriculture/buisness_market/b2b.dart'; // [cite: 5]
import 'package:agriculture/course/Course.dart'; // [cite: 5]
import 'package:agriculture/weatherforecast.dart'; // [cite: 6]
import 'package:agriculture/buisness_market/screen/marketplace_page.dart';

// --- Static Data & Constants ---
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
String weatherApiKey = // [cite: 14]
    '3e18874392caba4815ba03ce546fc1e9'; // Consider moving to a secure config

// --- Riverpod Providers ---

// Provider to get the current location (or null if unavailable)
// **MODIFIED:** Added more detailed error handling and logging
final locationProvider = FutureProvider<LocationData?>((ref) async {
  // [cite: 14]
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;

  try {
    dev.log("Checking location service...",
        name: "LocationProvider"); // [cite: 14]
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      dev.log("Location service disabled, requesting...", // [cite: 14]
          name: "LocationProvider");
      serviceEnabled = await location.requestService(); // [cite: 15]
      if (!serviceEnabled) {
        dev.log("Location service request denied.",
            name: "LocationProvider"); // [cite: 15]
        // Don't throw, allow app to proceed without location
        return null; // [cite: 15]
      }
      dev.log("Location service enabled.",
          name: "LocationProvider"); // [cite: 15]
    }

    dev.log("Checking location permission...",
        name: "LocationProvider"); // [cite: 15]
    permissionGranted = await location.hasPermission(); // [cite: 16]
    dev.log("Current permission status: $permissionGranted", // [cite: 16]
        name: "LocationProvider");
    if (permissionGranted == PermissionStatus.denied) {
      // [cite: 17]
      dev.log("Location permission denied, requesting...", // [cite: 17]
          name: "LocationProvider");
      permissionGranted = await location.requestPermission(); // [cite: 18]
      if (permissionGranted != PermissionStatus.granted) {
        dev.log("Location permission request denied.", // [cite: 18]
            name: "LocationProvider");
        // Don't throw, allow app to proceed without location
        return null; // [cite: 19]
      }
      dev.log("Location permission granted.",
          name: "LocationProvider"); // [cite: 20]
    }

    if (permissionGranted == PermissionStatus.deniedForever) {
      // [cite: 21]
      dev.log("Location permission denied forever.",
          name: "LocationProvider"); // [cite: 21]
      // Don't throw, allow app to proceed without location
      return null; // [cite: 22]
    }

    dev.log("Getting location data...", name: "LocationProvider"); // [cite: 23]
    // Add timeout to prevent hangs
    LocationData locationData = await location // [cite: 23]
        .getLocation()
        .timeout(
            const Duration(seconds: 15), // Adjust timeout as needed [cite: 23]
            onTimeout: () {
      throw TimeoutException("Location fetching timed out."); // [cite: 23]
    });
    dev.log(
        // [cite: 24]
        "Location fetched: Lat=${locationData.latitude}, Lon=${locationData.longitude}",
        name: "LocationProvider");
    return locationData; // [cite: 25]
  } catch (e, stackTrace) {
    dev.log("Error in LocationProvider: $e", // [cite: 25]
        error: e,
        stackTrace: stackTrace,
        name: "LocationProvider");
    // Return null instead of throwing to prevent app crash on startup
    return null; // [cite: 26]
  }
});

// Provider for Weather Data (fetches from API or cache)
// **MODIFIED:** Handles null locationData more gracefully
// **MODIFIED:** Simplified loading state handling
final weatherProvider = // [cite: 27]
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // Use watch to react to location changes/errors
  final locationAsyncValue = ref.watch(locationProvider); // [cite: 27]
  final prefs = await SharedPreferences.getInstance();

  Map<String, dynamic>? cachedData;
  String? storedWeatherData = prefs.getString('weatherData'); // [cite: 27]
  if (storedWeatherData != null && storedWeatherData.isNotEmpty) {
    try {
      cachedData =
          json.decode(storedWeatherData) as Map<String, dynamic>; // [cite: 27]
      dev.log("Initial weather data loaded from cache.", // [cite: 27]
          name: "WeatherProvider");
    } catch (e) {
      // [cite: 28]
      dev.log(
          "Error decoding cached weather data: $e. Clearing cache.", // [cite: 28]
          name: "WeatherProvider");
      await prefs.remove('weatherData'); // [cite: 28]
    }
  }

  // Process location result
  return await locationAsyncValue.when(
    // [cite: 28]
    data: (locationData) async {
      if (locationData?.latitude != null && locationData?.longitude != null) {
        final lat = locationData!.latitude; // [cite: 28]
        final lon = locationData.longitude; // [cite: 29]
        final url = // [cite: 29]
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$weatherApiKey';
        dev.log(
            "Fetching weather from API for Lat=$lat, Lon=$lon", // [cite: 30]
            name: "WeatherProvider");
        try {
          // [cite: 31]
          final response = await http // [cite: 31]
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
            // [cite: 32]
            final data = json.decode(response.body)
                as Map<String, dynamic>; // [cite: 32]
            dev.log('Weather data fetched successfully from API.', // [cite: 33]
                name: "WeatherProvider");
            // Save to cache asynchronously
            prefs.setString('weatherData', json.encode(data)); // [cite: 34]
            return data; // [cite: 34]
          } else {
            dev.log(
                // [cite: 35]
                'API Error ${response.statusCode}. Using cache if available.',
                name: "WeatherProvider");
            if (cachedData != null) return cachedData; // [cite: 36]
            throw Exception(
                'API error ${response.statusCode} and no cache.'); // [cite: 36]
          } // [cite: 37]
        } catch (e, stackTrace) {
          dev.log(
              'Network/Timeout Error: $e. Using cache if available.', // [cite: 37]
              error: e,
              stackTrace: stackTrace,
              name: "WeatherProvider");
          if (cachedData != null) return cachedData; // [cite: 38]
          throw Exception('Network/Fetch error and no cache: $e'); // [cite: 38]
        } // [cite: 39]
      } else {
        // Location data is null (likely permission denied or service off)
        dev.log(
            "Location data is null. Using cache if available.", // [cite: 39]
            name: "WeatherProvider");
        if (cachedData != null) return cachedData; // [cite: 40]
        throw Exception(
            'Location unavailable and no cached weather data.'); // [cite: 40]
      } // [cite: 41]
    },
    loading: () {
      // While location is loading, return cache immediately if available
      dev.log("Location provider loading. Checking cache...", // [cite: 41]
          name: "WeatherProvider");
      if (cachedData != null) {
        // [cite: 47]
        dev.log("Returning cached data while location loads.",
            name: "WeatherProvider");
        return cachedData; // Return stale data while loading fresh [cite: 47]
      }
      // Otherwise, let the loading state propagate.
      // The UI's .when clause for weatherProvider will show a loading indicator.
      dev.log("No cache, propagating loading state from location provider.",
          name: "WeatherProvider"); // [cite: 51]
      // Return a future that will not resolve, letting Riverpod handle AsyncLoading propagation
      return Completer<Map<String, dynamic>>()
          .future; // [cite: 50] is approximated by this line
    },
    error: (error, stack) async {
      // Error getting location
      dev.log(
          "Error from location provider: $error. Using cache if available.", // [cite: 55]
          error: error,
          stackTrace: stack,
          name: "WeatherProvider");
      if (cachedData != null) return cachedData; // [cite: 56]
      throw Exception(
          'Location error ($error) and no cached weather data.'); // [cite: 56]
    },
  );
});

// Provider for User Profile (Stream for real-time updates)
// **MODIFIED:** Added try-catch around stream creation
final userProfileProvider = // [cite: 57]
    StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  try {
    // [cite: 57]
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      dev.log("User not logged in for profile stream.", // [cite: 57]
          name: "UserProfileProvider");
      return Stream.value(null); // Handle logged-out state
    }
    dev.log("Setting up profile stream for user ${user.uid}", // [cite: 57]
        name: "UserProfileProvider");
    return FirebaseFirestore.instance // [cite: 58]
        .collection('profiles') // Ensure collection name is correct
        .doc(user.uid)
        .snapshots()
        .handleError((error, stackTrace) {
      // [cite: 58]
      // Add stream error handling
      dev.log("Error in profile stream: $error", // [cite: 58]
          error: error,
          stackTrace: stackTrace,
          name: "UserProfileProvider");
      // Depending on policy, either emit null or rethrow
      throw error; // Rethrow to propagate error state [cite: 59]
    }).map((snapshot) {
      dev.log(
          "Profile snapshot received. Exists: ${snapshot.exists}", // [cite: 59]
          name: "UserProfileProvider");
      return snapshot.data(); // [cite: 59]
    });
  } catch (e, stackTrace) {
    // [cite: 60]
    dev.log("Error creating profile stream: $e", // [cite: 60]
        error: e,
        stackTrace: stackTrace,
        name: "UserProfileProvider");
    // Return a stream that emits the error
    return Stream.error('Failed to load profile: $e', stackTrace); // [cite: 61]
  }
});

// Provider for Scheduled Tasks (Stream for real-time updates)
// **MODIFIED:** Added try-catch around stream creation
final scheduledTasksProvider = // [cite: 62]
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  try {
    // [cite: 62]
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      dev.log("User not logged in for tasks stream.", // [cite: 62]
          name: "ScheduledTasksProvider");
      return Stream.value([]); // Handle logged-out state
    }
    dev.log("Setting up tasks stream for user ${user.uid}", // [cite: 62]
        name: "ScheduledTasksProvider");
    return FirebaseFirestore.instance // [cite: 63]
        .collection('users') // Ensure collection name is correct
        .doc(user.uid)
        .collection('scheduledTasks') // Ensure subcollection name is correct
        .orderBy('date') // [cite: 63]
        .snapshots()
        .handleError((error, stackTrace) {
      // [cite: 63]
      // Add stream error handling
      dev.log("Error in tasks stream: $error", // [cite: 63]
          error: error,
          stackTrace: stackTrace,
          name: "ScheduledTasksProvider");
      // Return empty list on error or rethrow
      return <Map<String, dynamic>>[]; // Or throw error; [cite: 64]
    }).map((snapshot) {
      // [cite: 65]
      dev.log(
          "Tasks snapshot received. Count: ${snapshot.docs.length}", // [cite: 65]
          name: "ScheduledTasksProvider");
      return snapshot.docs.map((doc) {
        // [cite: 65]
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  } catch (e, stackTrace) {
    // [cite: 66]
    dev.log("Error creating tasks stream: $e", // [cite: 66]
        error: e,
        stackTrace: stackTrace,
        name: "ScheduledTasksProvider");
    // Return a stream that emits the error
    return Stream.error('Failed to load tasks: $e', stackTrace); // [cite: 67]
  }
});

// --- Utility Functions ---

final FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin = // [cite: 68]
    FlutterLocalNotificationsPlugin();
Future<void> _showNotification(String title, String body) async {
  // [cite: 69]
  // (Keep notification logic as is)
  try {
    // [cite: 69]
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      // [cite: 69]
      'weather_alert_channel', // id
      'Weather Alerts', // title
      description: 'Weather alerts for farmers', // description
      importance: Importance.max,
    );
    AndroidNotificationDetails androidNotificationDetails = // [cite: 70]
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: channel.importance,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics = // [cite: 71]
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      // [cite: 72]
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    dev.log("Notification shown: '$title'", name: "Notification"); // [cite: 73]
  } catch (e) {
    dev.log('Error showing notification: $e',
        name: "Notification"); // [cite: 73]
  } // [cite: 74]
}

Future<void> _launchUrl(String url) async {
  // [cite: 74]
  final Uri uri = Uri.parse(url); // [cite: 74]
  try {
    // [cite: 75]
    dev.log("Launching URL: $url", name: "URL Launcher"); // [cite: 75]
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // [cite: 76]
      dev.log('Could not launch $uri', name: "URL Launcher"); // [cite: 76]
      // Optionally show a snackbar or dialog [cite: 77]
    } else {
      dev.log("URL launched successfully.", name: "URL Launcher"); // [cite: 77]
    } // [cite: 78]
  } catch (e) {
    dev.log("Error launching URL $url: $e", name: "URL Launcher"); // [cite: 78]
    // Optionally show a snackbar or dialog [cite: 79]
  }
}

// --- Main Home Page Widget ---

class HomePage extends ConsumerStatefulWidget {
  // [cite: 79]
  const HomePage({super.key}); // [cite: 79]
  @override // [cite: 80]
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // [cite: 80]
  int _selectedIndex = 0;
  String _languageCode = 'en'; // [cite: 80]
  @override // [cite: 81]
  void initState() {
    super.initState();
    dev.log("HomePage initState", name: "HomePage"); // [cite: 81]
    _loadLanguage(); // [cite: 81]

    // **REMOVED:** Initial ref.read(...).then(...) call. // [cite: 81]
    // Let `ref.watch` in build handle initial loading. // [cite: 82]
    // If you need to react *after* the first build:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) { // Check if widget is still mounted
    //     final weatherAsync = ref.read(weatherProvider);
    //     // Check weather state and potentially show notification
    //   }
    // });
  } // [cite: 83]

  Future<void> _loadLanguage() async {
    // [cite: 83]
    dev.log("Loading language...", name: "HomePage"); // [cite: 83]
    _languageCode = await getLanguageCode(); // [cite: 83]
    if (mounted) {
      // [cite: 84] <- This 'mounted' is OK (in StatefulWidget's State)
      dev.log("Language set to: $_languageCode",
          name: "HomePage"); // [cite: 84]
      setState(() {}); // [cite: 84]
    } // [cite: 85]
  }

  Future<String> getLanguageCode() async {
    // [cite: 85]
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // [cite: 85]
    return prefs.getString('language') ?? 'en'; // [cite: 85]
  } // [cite: 86]

  void _onItemTapped(int index) {
    // [cite: 86]
    dev.log("Bottom nav tapped: index $index", name: "HomePage"); // [cite: 86]
    setState(() {
      // [cite: 87]
      _selectedIndex = index; // [cite: 87]
    });
  } // [cite: 88]

  @override
  Widget build(BuildContext context) {
    // [cite: 88]
    dev.log("HomePage build method", name: "HomePage"); // [cite: 88]
    // Access providers using ref.watch
    final userProfileAsyncValue = ref.watch(userProfileProvider); // [cite: 89]
    // Watch other providers if needed directly in build for error checking
    // Watching them here ensures they are initialized. Their states (loading/error/data)
    // will be handled within the widgets that actually use their data (e.g., CropDetailsPage).
    ref.watch(locationProvider); // Initialize location early [cite: 90]
    ref.watch(weatherProvider); // Initialize weather early [cite: 90]
    ref.watch(scheduledTasksProvider); // Initialize tasks early [cite: 90]

    Locale myLocale = Locale(_languageCode); // [cite: 91]
    AppLocalizations localizations = AppLocalizations(myLocale); // [cite: 91]

    return Scaffold(
      appBar: AppBar(
        // [cite: 112]
        // Set automaticallyImplyLeading to false if you are handling the leading widget manually
        automaticallyImplyLeading: false,
        // Leading icon (e.g., menu icon) on the left
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white), // Set icon color
            onPressed: () {
              // Handle menu icon press
              // Now you can safely use Scaffold.of(context) here to open the Drawer
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        // Title containing the greeting, notification icon, and avatar arranged in a Row
        title: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Distribute space between children
          children: <Widget>[
            // Greeting text
            Expanded(
              // Use Expanded to allow the text to take available space
              child: Text(
                'AgriIot', // Replace with dynamic user name if needed
                style: TextStyle(
                  color: Colors.white, // Set text color
                  fontSize: 18.0, // Adjust font size as needed
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'Poppins', // Uncomment and ensure Poppins is in pubspec.yaml
                ),
                overflow: TextOverflow.ellipsis, // Prevent text overflow
              ),
            ),
            // Row for notification icon and avatar on the right
            Row(
              children: [
                // Notification icon
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: Colors.white), // Set icon color
                  onPressed: () {
                    // Handle notification icon press
                  },
                ),
                // Add some spacing between the icon and the avatar
                SizedBox(width: 8),
                // Avatar image (replace with your image asset or network image)
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://avatars.githubusercontent.com/u/43668321?v=4'), // Replace with your image URL
                  radius: 20.0, // Adjust avatar size
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        // [cite: 91]
        backgroundColor: Colors.white, // [cite: 91]
        child: ListView(
          padding: EdgeInsets.zero, // [cite: 91]
          children: [
            // --- Drawer Header ---
            userProfileAsyncValue.when(
                // [cite: 91]
                data: (profile) {
                  // [cite: 92]
                  dev.log(
                      "Building drawer header with profile data.", // [cite: 92]
                      name: "HomePage");
                  return UserAccountsDrawerHeader(
                    // [cite: 92]
                    accountName:
                        Text(profile?['username'] ?? 'Username'), // [cite: 92]
                    accountEmail:
                        Text(profile?['email'] ?? 'Email'), // [cite: 93]
                    currentAccountPicture: const CircleAvatar(
                      // [cite: 93]
                      backgroundImage: NetworkImage(// [cite: 93]
                          'https://avatars.githubusercontent.com/u/43668321?v=4'), // Replace with dynamic URL if available
                    ), // [cite: 94]
                    decoration: BoxDecoration(
                        // [cite: 94]
                        gradient: LinearGradient(colors: [
                      Colors.lightBlue.shade400, // [cite: 94]
                      Colors.blue.shade700 // [cite: 95]
                    ])),
                  ); // [cite: 95]
                }, // [cite: 96]
                loading: () => UserAccountsDrawerHeader(
                      // [cite: 96]
                      // Placeholder while loading
                      accountName: Text("Loading..."), // [cite: 96]
                      accountEmail: Text(""), // [cite: 96]
                      decoration: BoxDecoration(
                          // [cite: 97]
                          gradient: LinearGradient(colors: [
                        Colors.lightBlue.shade400, // [cite: 97]
                        Colors.blue.shade700 // [cite: 97]
                      ])), // [cite: 98]
                    ),
                error: (error, stack) => UserAccountsDrawerHeader(
                      // [cite: 98]
                      // Error state
                      accountName: Text("Error"), // [cite: 98]
                      accountEmail: Text("$error"), // [cite: 99]
                      decoration: BoxDecoration(
                          // [cite: 99]
                          gradient: LinearGradient(colors: [
                        Colors.grey.shade400, // [cite: 99]
                        Colors.grey.shade700 // [cite: 100]
                      ])),
                    )),
            ListTile(
              title: const Text('Explore Learning'), // [cite: 100]
              onTap: () {
                // [cite: 101]
                Navigator.push(
                    context, // [cite: 101]
                    MaterialPageRoute(
                        builder: (context) => // [cite: 101]
                            const CoursePage())); // [cite: 102]
              }, // [cite: 103]
            ),
            ListTile(
              title: const Text('Weather Forecast'), // [cite: 103]
              onTap: () {
                Navigator.push(
                    // [cite: 103]
                    context, // [cite: 104]
                    MaterialPageRoute(
                        // [cite: 104]
                        builder: (context) => WeatherForecastWidget(
                              // [cite: 104]
                              apiKey: weatherApiKey, // [cite: 105]
                            )));
              },
            ),
            ListTile(
                title: const Text('Settings'), // [cite: 106]
                onTap: () {
                  // [cite: 106]
                  Navigator.push(
                      context, // [cite: 106]
                      MaterialPageRoute(
                        // [cite: 106]
                        builder: (context) =>
                            const SettingPage(), // [cite: 107]
                      ));
                }),
            ListTile(
                title: const Text('About'), // [cite: 107]
                onTap: () {
                  // [cite: 108]
                  Navigator.push(
                    // [cite: 108]
                    context, // [cite: 108]
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(), // [cite: 108]
                    ), // [cite: 109]
                  ); // [cite: 109]
                }), // [cite: 110]
            // Add Sign Out Button
            //  ListTile(
            //    leading: Icon(Icons.logout, color: Colors.red),
            //    title: const Text('Sign Out'),
            //    onTap: () async {
            //      await FirebaseAuth.instance.signOut(); // [cite: 111]
            //      // Optionally navigate to login screen
            //      Navigator.of(context).pushReplacement(/* ... route to login page ... */);
            //    },
            //  ),
          ], // [cite: 111]
        ), // [cite: 112]
      ),
      body: RefreshIndicator(
        // [cite: 117]
        onRefresh: () async {
          // [cite: 118]
          dev.log("Refreshing data...", name: "HomePage"); // [cite: 118]
          // Invalidate providers to trigger refetch
          ref.invalidate(locationProvider); // [cite: 119]
          // Refresh location first
          // Allow some time for location to resolve before refreshing weather
          await Future.delayed(
              const Duration(milliseconds: 100)); // [cite: 120]
          ref.invalidate(weatherProvider); // [cite: 121]
          ref.invalidate(userProfileProvider); // [cite: 121]
          ref.invalidate(scheduledTasksProvider); // [cite: 121]
          // Add other providers if needed

          // Optional: Wait for essential providers to finish reloading
          // This ensures the refresh indicator stays until data is loaded.
          try {
            // [cite: 121]
            await ref.read(weatherProvider.future); // [cite: 121]
            await ref.read(// [cite: 122]
                userProfileProvider.future); // Wait for first emit of profile
            await ref.read(// [cite: 123]
                scheduledTasksProvider.future); // Wait for first emit of tasks
            dev.log("Refresh complete.", name: "HomePage"); // [cite: 124]
          } catch (e) {
            // [cite: 125]
            dev.log("Error waiting for providers during refresh: $e",
                name: "HomePage"); // [cite: 125]
            // Handle error, maybe show a snackbar
            if (mounted) {
              // <- This 'mounted' is OK (in StatefulWidget's State) [cite: 126]
              ScaffoldMessenger.of(context).showSnackBar(
                // [cite: 126]
                SnackBar(
                    content: Text(
                        "Error refreshing data: ${e.toString()}")), // [cite: 126]
              );
            } // [cite: 127]
          }
        },
        // --- Child of RefreshIndicator ---
        child: Center(
          // [cite: 127]
          // Build the selected screen based on the index
          child: _buildSelectedScreen(
              // [cite: 127]
              _selectedIndex,
              localizations), // Pass localizations
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: CurvedNavigationBar(
        // [cite: 128]
        index: _selectedIndex, // [cite: 128]
        onTap: _onItemTapped, // Use the local method [cite: 128]
        backgroundColor: Colors.lightBlue[400]!, // [cite: 128]
        buttonBackgroundColor: Colors.blue[700]!, // [cite: 128]
        color: Colors.lightBlue[100]!, // [cite: 128]
        height: 70, // [cite: 128]
        animationCurve: Curves.easeIn, // [cite: 129]
        animationDuration: const Duration(milliseconds: 300), // [cite: 129]
        items: [
          CurvedNavigationBarItem(
              // [cite: 129]
              child: Icon(
                Icons.home_outlined, // [cite: 129]
                color: _selectedIndex == 0 ? Colors.white : null, // [cite: 130]
              ),
              label: localizations.home, // Use localized string [cite: 130]
              labelStyle: TextStyle(
                  // [cite: 130]
                  color: _selectedIndex == 0 ? Colors.white : Colors.black54)),
          CurvedNavigationBarItem(
              // [cite: 130]
              child: Icon(
                // [cite: 131]
                Icons.crop, // [cite: 131]
                color: _selectedIndex == 1 ? Colors.white : null, // [cite: 131]
              ),
              label: localizations.disease, // Use localized string [cite: 131]
              labelStyle: TextStyle(
                  // [cite: 132]
                  color: _selectedIndex == 1 ? Colors.white : Colors.black54)),
          CurvedNavigationBarItem(
              // [cite: 132]
              child: Icon(
                Icons.store, // [cite: 132]
                color: _selectedIndex == 2 ? Colors.white : null, // [cite: 132]
              ), // [cite: 133]
              label: // [cite: 133]
                  localizations.marketplace, // Use localized string [cite: 133]
              labelStyle: TextStyle(
                  // [cite: 133]
                  color: _selectedIndex == 2
                      ? Colors.white
                      : Colors.black54)), // [cite: 134]
          CurvedNavigationBarItem(
              // [cite: 134]
              child: Icon(
                Icons.menu_book_outlined, // [cite: 134]
                color: _selectedIndex == 3 ? Colors.white : null, // [cite: 134]
              ),
              label: localizations.course, // [cite: 134]
              labelStyle: TextStyle(
                  // [cite: 135]
                  color: _selectedIndex == 3 ? Colors.white : Colors.black54)),
        ],
      ),
    ); // [cite: 135]
  }

  // Helper to build the currently selected screen/widget
  Widget _buildSelectedScreen(int index, AppLocalizations localizations) {
    // [cite: 136]
    // Note: Passing ref down might be needed if sub-pages are ConsumerWidgets
    // and need to perform actions (like read/invalidate).
    // Watching state // [cite: 137]
    // works automatically as they are already ConsumerWidgets. // [cite: 137]
    switch (index) {
      // [cite: 138]
      case 0:
        // CropDetailsPage is now a ConsumerWidget, it gets ref automatically
        return const CropDetailsPage(); // [cite: 138]
      case 1:
        // Assuming DiseaseDetectionPage doesn't need Riverpod state directly here
        return const CropMonitoringPage(); // [cite: 139]
      case 2: // [cite: 140]
        // Assuming MarketplaceScreen doesn't need Riverpod state directly here
        return const MarketplacePage(); // [cite: 140]
      case 3: // [cite: 141]
        // Assuming CoursesPage doesn't need Riverpod state directly here
        return const CoursesPage(); // [cite: 141]
      default: // [cite: 142]
        return const CropDetailsPage(); // [cite: 142]
    } // [cite: 143]
  }
}

// --- Crop Details Page (Main content for the first tab) ---

class CropDetailsPage extends ConsumerWidget {
  // [cite: 143]
  // Changed to ConsumerWidget
  const CropDetailsPage({super.key}); // [cite: 143]
  @override // [cite: 144]
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref [cite: 144]
    // Watch the providers needed for this page
    final weatherAsyncValue = ref.watch(weatherProvider); // [cite: 144]
    final tasksAsyncValue = ref.watch(scheduledTasksProvider); // [cite: 145]

    // The RefreshIndicator is wrapping the body in HomePage,
    // so this ListView allows the content to be scrollable, enabling refresh.
    return ListView(
        // [cite: 145]
        // Ensure content is scrollable
        padding:
            EdgeInsets.zero, // Remove default padding if needed [cite: 146]
        children: [
          // --- Weather Card ---
          weatherAsyncValue.when(
            // [cite: 146]
            data: (weatherData) => // [cite: 146]
                buildWeatherCard(context, weatherData), // Pass data
            loading: () => const Padding(
              // [cite: 147]
              // Loading indicator for weather
              padding: EdgeInsets.all(16.0), // [cite: 147]
              child: Center(child: CircularProgressIndicator()), // [cite: 147]
            ),
            error: (error, stack) => Padding(
              // [cite: 147]
              // Error display for weather [cite: 148]
              padding: const EdgeInsets.all(16.0), // [cite: 148]
              child: Center(
                  child: Text('Error loading weather:\n$error', // [cite: 148]
                      textAlign: TextAlign.center)),
            ),
          ), // [cite: 149]

          // --- Irrigation Scheduler Card ---
          tasksAsyncValue.when(
            // [cite: 149]
            data: (tasks) => // [cite: 149]
                buildSchedulerCard(context, tasks, ref), // Pass data and ref
            loading: () => const Padding(
              // [cite: 149]
              // Loading indicator for tasks
              padding: EdgeInsets.all(16.0), // [cite: 150]
              child: Center(child: CircularProgressIndicator()), // [cite: 150]
            ),
            error: (error, stack) => Padding(
              // [cite: 150]
              // Error display for tasks
              padding: const EdgeInsets.all(16.0), // [cite: 150]
              child: Center(
                  // [cite: 151]
                  child: Text('Error loading tasks:\n$error', // [cite: 151]
                      textAlign: TextAlign.center)),
            ),
          ),

          // --- Soil Data Section ---
          // Assuming static data for now, otherwise wrap in a provider watch [cite: 151]
          buildSoilDataSection(context), // [cite: 152]

          // --- Schemes Section ---
          // Assuming static JSON data, otherwise wrap in a provider watch [cite: 152]
          buildSchemesSection(context), // [cite: 152]
        ]); // [cite: 152]
  }

  // --- Extracted Build Logic Functions for CropDetailsPage ---

  Widget buildWeatherCard(
      // [cite: 153]
      BuildContext context,
      Map<String, dynamic> weatherData) {
    // Use the weatherData map directly
    String description =
        weatherData['weather']?[0]?['description'] ?? 'N/A'; // [cite: 153]
    String name = weatherData['name'] ?? 'Unknown Location'; // [cite: 154]
    // Temp is already in Celsius (metric)
    String temp =
        weatherData['main']?['temp']?.toStringAsFixed(0) ?? '--'; // [cite: 154]
    String humidity = // [cite: 155]
        weatherData['main']?['humidity']?.toString() ?? '--'; // [cite: 155]
    String windSpeed = // [cite: 156]
        weatherData['wind']?['speed']?.toString() ?? '--'; // [cite: 156]

    return GestureDetector(
      // [cite: 157]
      // Keep gesture detector if needed [cite: 157]
      onTap: () {
        Navigator.push(
          // [cite: 157]
          context, // [cite: 157]
          MaterialPageRoute(
              builder: (context) => // [cite: 157]
                  WeatherForecastWidget(apiKey: weatherApiKey)),
        ); // [cite: 158]
      },
      child: Hero(
        // [cite: 158]
        // Keep Hero if WeatherForecastWidget uses it [cite: 158]
        tag: 'weather', // [cite: 158]
        child: Container(
          // [cite: 158]
          decoration: BoxDecoration(
            // [cite: 158]
            gradient: LinearGradient(
              // [cite: 158]
              colors: [
                Colors.lightBlue.shade200,
                Colors.blue.shade400
              ], // [cite: 159]
              begin: Alignment.topLeft, // [cite: 159]
              end: Alignment.bottomRight, // [cite: 159]
            ),
            boxShadow: [
              // [cite: 159]
              BoxShadow(
                // [cite: 160]
                color: Colors.blue.withOpacity(0.3), // [cite: 160]
                spreadRadius: 2, // [cite: 160]
                blurRadius: 10, // [cite: 160]
                offset: Offset(0, 3), // [cite: 160]
              ), // [cite: 161]
            ],
            borderRadius: BorderRadius.circular(15), // [cite: 161]
          ),
          padding: const EdgeInsets.all(16.0), // [cite: 161]
          margin: const EdgeInsets.all(13.0), // [cite: 161]
          child: Column(
            // [cite: 161]
            crossAxisAlignment: CrossAxisAlignment.start, // [cite: 162]
            children: <Widget>[
              Row(
                // [cite: 162]
                mainAxisAlignment: // [cite: 162]
                    MainAxisAlignment.spaceBetween, // Align title and location
                children: <Widget>[
                  // [cite: 162]
                  Row(
                    // [cite: 163]
                    // Group icon and title
                    children: [
                      Icon(Icons.cloud, // [cite: 163]
                          color: Colors.white, // [cite: 164]
                          size: 40), // Adjusted color/size [cite: 164]
                      SizedBox(width: 10), // [cite: 164]
                      Text('Weather Report', // [cite: 165]
                          style: TextStyle(
                              color: Colors.white, // Adjusted color [cite: 165]
                              fontSize: 20, // [cite: 165]
                              fontWeight: FontWeight.bold, // [cite: 166]
                              fontFamily: 'Poppins')), // [cite: 166]
                    ],
                  ), // [cite: 167]
                  Text(name, // Display city name [cite: 167]
                      style: TextStyle(
                          // [cite: 167]
                          color: Colors.white70, // [cite: 167]
                          fontSize: 16, // [cite: 168]
                          fontFamily: 'Poppins')), // [cite: 168]
                ],
              ),
              const Divider(
                  // [cite: 168]
                  color: Colors.white54), // Adjusted color [cite: 168]
              Row(
                // [cite: 169]
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // [cite: 169]
                children: <Widget>[
                  _buildWeatherInfoColumn(
                      Icons.thermostat,
                      Colors.redAccent, // [cite: 169]
                      'Temperature',
                      '$temp °C'), // [cite: 170]
                  _buildWeatherInfoColumn(
                      // [cite: 170]
                      Icons.water_drop_outlined, // [cite: 170]
                      Colors.blue.shade100, // [cite: 170]
                      'Humidity', // [cite: 170]
                      '$humidity %'), // Adjusted icon [cite: 171]
                  _buildWeatherInfoColumn(
                      Icons.air,
                      Colors.grey.shade300, // [cite: 171]
                      'Wind Speed',
                      '$windSpeed m/s'), // [cite: 171]
                ],
              ),
              const SizedBox(height: 8), // Add some space [cite: 172]
              Text(
                  // [cite: 172]
                  // Display weather description
                  'Currently: ${description.isNotEmpty ? description[0].toUpperCase() + description.substring(1) : 'N/A'}', // [cite: 172]
                  style: TextStyle(
                      // [cite: 173]
                      color: Colors.white, // [cite: 173]
                      fontSize: 15, // [cite: 173]
                      fontFamily: 'Poppins')), // [cite: 173]
            ], // [cite: 174]
          ),
        ),
      ),
    ); // [cite: 174]
  }

  // Helper for weather columns
  Widget _buildWeatherInfoColumn(
      // [cite: 175]
      IconData icon,
      Color iconColor,
      String label,
      String value) {
    return Column(
      // [cite: 175]
      children: <Widget>[
        Icon(icon, color: iconColor, size: 28), // [cite: 175]
        const SizedBox(height: 4), // [cite: 175]
        Text(label, // [cite: 175]
            style: TextStyle(
                color: Colors.white70, // [cite: 176]
                fontFamily: 'Poppins', // [cite: 176]
                fontSize: 13)), // [cite: 176]
        const SizedBox(height: 2), // [cite: 176]
        Text(value, // [cite: 176]
            style: const TextStyle(
                // [cite: 176]
                color: Colors.white, // [cite: 176]
                fontWeight: FontWeight.bold, // [cite: 177]
                fontFamily: 'Poppins', // [cite: 177]
                fontSize: 15)), // [cite: 177]
      ],
    ); // [cite: 177]
  }

  Widget buildSchedulerCard(
      BuildContext context, // [cite: 178]
      List<Map<String, dynamic>> scheduledTasks,
      WidgetRef ref) {
    return Container(
      // [cite: 178]
      constraints: const BoxConstraints(
          // [cite: 178]
          minHeight: 180), // Use minHeight instead of maxHeight
      decoration: BoxDecoration(
        // [cite: 178]
        borderRadius: BorderRadius.circular(20), // [cite: 178]
      ),
      margin: const EdgeInsets.symmetric(
          // [cite: 178]
          horizontal: 13.0,
          vertical: 8.0), // Adjusted margin [cite: 178]
      child: Card(
        // [cite: 179]
        elevation: 5, // Reduced elevation slightly [cite: 179]
        shape: RoundedRectangleBorder(
            // [cite: 179]
            borderRadius: // [cite: 179]
                BorderRadius.circular(15)), // Adjusted radius [cite: 179]
        child: Container(
          // [cite: 180]
          decoration: BoxDecoration(
            // [cite: 180]
            gradient: LinearGradient(
              // [cite: 180]
              colors: [
                // [cite: 180]
                Colors.green.shade400, // [cite: 180]
                Colors.green.shade600 // [cite: 181]
              ], // Adjusted gradient [cite: 181]
              begin: Alignment.topLeft, // [cite: 181]
              end: Alignment.bottomRight, // [cite: 181]
            ),
            borderRadius: BorderRadius.circular(15), // [cite: 181]
            // Removed shadow from inner container, Card provides elevation [cite: 182]
          ),
          child: Padding(
            // [cite: 182]
            padding: const EdgeInsets.all(16.0), // [cite: 182]
            child: Column(
              // [cite: 182]
              crossAxisAlignment: CrossAxisAlignment.start, // [cite: 182]
              children: <Widget>[
                // [cite: 183]
                Row(
                  // [cite: 183]
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // [cite: 183]
                  children: [
                    Row(
                      // [cite: 184]
                      // Group icon and title [cite: 184]
                      children: [
                        Icon(Icons.timer, // [cite: 184]
                            color: Colors.white), // White icon [cite: 185]
                        SizedBox(width: 3), // [cite: 185]
                        Text(
                          // [cite: 185]
                          'Irrigation Scheduler', // [cite: 186]
                          style: TextStyle(
                            // [cite: 186]
                            color: Colors.white, // White text [cite: 186]
                            fontSize: 15, // Increased size [cite: 187]
                            fontWeight: FontWeight.bold, // [cite: 187]
                            fontFamily: 'Poppins', // [cite: 187]
                          ), // [cite: 188]
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      // [cite: 188]
                      // Use ElevatedButton.icon [cite: 189]
                      style: ElevatedButton.styleFrom(
                        // [cite: 189]
                        backgroundColor: // [cite: 189]
                            Colors.white, // Button color [cite: 190]
                        foregroundColor: Colors // [cite: 190]
                            .green
                            .shade700, // Text/icon color [cite: 190]
                        shape: RoundedRectangleBorder(
                            // [cite: 191]
                            borderRadius:
                                BorderRadius.circular(20)), // [cite: 191]
                      ),
                      onPressed: () {
                        // [cite: 191]
                        Navigator.push(
                          // [cite: 192]
                          context, // [cite: 192]
                          MaterialPageRoute(
                              // [cite: 192]
                              builder: (context) => // [cite: 193]
                                  SchedulerPage()), // Navigate to your scheduler page [cite: 193]
                        ); // [cite: 193]
                      }, // [cite: 194]
                      icon: Icon(Icons.add, size: 15), // [cite: 194]
                      label: const Text('Add'), // Shortened text [cite: 194]
                    ),
                  ], // [cite: 195]
                ),
                const Divider(
                    // [cite: 195]
                    height: 20, // [cite: 195]
                    thickness: 1, // [cite: 195]
                    color: Colors.white30), // Divider color [cite: 195]
                // --- Task List --- [cite: 196]
                if (scheduledTasks.isEmpty) // [cite: 196]
                  Padding(
                    // [cite: 196]
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0), // [cite: 196]
                    child: Center(
                      // [cite: 196]
                      child: Text(
                        // [cite: 197]
                        'No scheduled irrigation tasks.', // More specific text [cite: 197]
                        style: TextStyle(
                            // [cite: 197]
                            color: Colors.white70, // [cite: 198]
                            fontSize: 15), // Themed text [cite: 198]
                      ),
                    ),
                  ) // [cite: 198]
                else // [cite: 199]
                  // Use SizedBox for fixed height or Flexible/Expanded if inside a Column with other flexible children
                  SizedBox(
                    // [cite: 199]
                    height:
                        100, // Give the horizontal list a defined height [cite: 199]
                    child: ListView.builder(
                      // [cite: 200]
                      // Use ListView.builder for efficiency
                      scrollDirection: Axis.horizontal, // [cite: 200]
                      itemCount: scheduledTasks.length, // [cite: 200]
                      itemBuilder: (context, index) {
                        // [cite: 201]
                        final task = scheduledTasks[index]; // [cite: 201]
                        final description =
                            (task['description'] as String? ?? '').substring(
                                0,
                                min(
                                    10,
                                    (task['description'] as String?)!
                                        .length)); // [cite: 202]
                        'No Description'; // [cite: 202]
                        final dateString = // [cite: 202]
                            task['date'] as String?; // [cite: 202]
                        final timeString = // [cite: 203]
                            task['time'] as String? ?? 'No Time'; // [cite: 204]
                        final taskId = task['id'] // [cite: 204]
                            as String?; // Get the document ID added in the provider [cite: 205]

                        String formattedDate = 'Invalid Date'; // [cite: 205]
                        if (dateString != null) {
                          // [cite: 206]
                          try {
                            // [cite: 206]
                            final dateTime = // [cite: 207]
                                DateTime.parse(dateString); // [cite: 207]
                            formattedDate = DateFormat(
                                    'dd MMM,𒑊') // [cite: 208]
                                .format(dateTime); // Updated format [cite: 208]
                          } catch (e) {
                            // [cite: 209]
                            dev.log(
                                // [cite: 209]
                                'Error parsing date "$dateString": $e',
                                name: "SchedulerCard");
                            formattedDate = 'Date Error'; // [cite: 210]
                          } // [cite: 211]
                        }

                        return Container(
                          // [cite: 211]
                          width: // [cite: 212]
                              160, // Give cards a fixed width in horizontal list
                          margin: const EdgeInsets.symmetric(
                              // [cite: 212]
                              horizontal: 6,
                              vertical: 5), // [cite: 213]
                          decoration: BoxDecoration(
                              // [cite: 213]
                              color: Colors.white.withOpacity(// [cite: 214]
                                  0.9), // Use white background [cite: 214]
                              borderRadius: // [cite: 214]
                                  BorderRadius.circular(10), // [cite: 215]
                              boxShadow: [
                                // [cite: 215]
                                BoxShadow(
                                  // [cite: 216]
                                  color: Colors.black.withOpacity(// [cite: 216]
                                      0.1), // Softer shadow [cite: 217]
                                  spreadRadius: 1, // [cite: 217]
                                  blurRadius: 4, // [cite: 217]
                                  offset: const Offset(0, 2), // [cite: 218]
                                ),
                              ]),
                          child: Stack(
                            // [cite: 219]
                            // Use Stack for delete button [cite: 219]
                            children: [
                              Padding(
                                // [cite: 220]
                                padding: const EdgeInsets.all(
                                        10.0) // [cite: 220]
                                    .copyWith(
                                        right:
                                            30), // Adjust padding [cite: 221]
                                child: Column(
                                  // [cite: 221]
                                  crossAxisAlignment: // [cite: 222]
                                      CrossAxisAlignment.start, // [cite: 222]
                                  mainAxisAlignment:
                                      MainAxisAlignment // [cite: 222]
                                          .center, // Center content vertically [cite: 223]
                                  children: [
                                    // [cite: 223]
                                    Text(
                                      // [cite: 224]
                                      // Description [cite: 224]
                                      description, // [cite: 224]
                                      maxLines: 2, // [cite: 225]
                                      overflow: TextOverflow // [cite: 225]
                                          .ellipsis, // Handle overflow [cite: 226]
                                      style: const TextStyle(
                                          // [cite: 226]
                                          fontSize: 15, // [cite: 227]
                                          fontWeight:
                                              FontWeight.bold, // [cite: 227]
                                          color: Colors
                                              .black87, // Adjust color [cite: 228]
                                          fontFamily: 'Poppins'), // [cite: 228]
                                    ), // [cite: 229]
                                    const SizedBox(height: 4), // [cite: 229]
                                    Text(
                                      // [cite: 229]
                                      // Date [cite: 230]
                                      formattedDate, // [cite: 230]
                                      style: Theme.of(context) // [cite: 231]
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Colors
                                                  .black54), // [cite: 232]
                                    ), // [cite: 232]
                                    Text(
                                      // [cite: 233]
                                      // Time [cite: 233]
                                      timeString, // [cite: 233]
                                      style: Theme.of(context) // [cite: 234]
                                          .textTheme
                                          .bodySmall // [cite: 235]
                                          ?.copyWith(
                                              color: Colors
                                                  .black54), // [cite: 235]
                                    ),
                                  ], // [cite: 236]
                                ),
                              ), // [cite: 236]
                              // --- Delete Button --- [cite: 237]
                              Positioned(
                                // [cite: 237]
                                right: -5, // Adjust position [cite: 238]
                                top: -5, // Adjust position [cite: 238]
                                child: IconButton(
                                  // [cite: 238]
                                  icon: const Icon(
                                      // [cite: 239]
                                      Icons
                                          .close_rounded, // Use close icon [cite: 239]
                                      color: Colors.redAccent, // [cite: 240]
                                      size: 20), // [cite: 240]
                                  tooltip: "Delete Task", // [cite: 241]
                                  onPressed: taskId == null // [cite: 241]
                                      ? null // [cite: 242]
                                      : () async {
                                          // Disable if no ID [cite: 242]
                                          // Show confirmation dialog [cite: 243]
                                          bool? // [cite: 243]
                                              deleteConfirmed = // [cite: 244]
                                              await showDialog<bool>(
                                            context: context, // [cite: 244]
                                            builder: (BuildContext context) {
                                              // [cite: 245]
                                              return AlertDialog(
                                                // [cite: 245]
                                                title: const Text(// [cite: 246]
                                                    'Confirm Deletion'), // [cite: 246]
                                                content: Text(// [cite: 247]
                                                    'Are you sure you want to delete the task "$description"?'), // [cite: 247]
                                                actions: <Widget>[
                                                  // [cite: 248]
                                                  TextButton(
                                                    // [cite: 248]
                                                    child: const Text(
                                                        'Cancel'), // [cite: 249]
                                                    onPressed: () {
                                                      // [cite: 250]
                                                      Navigator.of(context).pop(
                                                          // [cite: 250]
                                                          false); // Return false [cite: 251]
                                                    }, // [cite: 252]
                                                  ), // [cite: 253]
                                                  TextButton(
                                                    // [cite: 253]
                                                    style: TextButton.styleFrom(
                                                        // [cite: 254]
                                                        foregroundColor: // [cite: 254]
                                                            Colors
                                                                .red), // [cite: 255]
                                                    child: const Text(
                                                        'Delete'), // [cite: 255]
                                                    onPressed: () {
                                                      // [cite: 256]
                                                      Navigator.of(context).pop(
                                                          // [cite: 256]
                                                          true); // Return true [cite: 257]
                                                    },
                                                  ), // [cite: 258]
                                                ],
                                              ); // [cite: 259]
                                            }, // [cite: 260]
                                          );
                                          if (deleteConfirmed == true) {
                                            // [cite: 261]
                                            // Proceed with deletion
                                            dev.log(
                                                // [cite: 261]
                                                "Deleting task with ID: $taskId",
                                                name:
                                                    "SchedulerCard"); // [cite: 262]
                                            try {
                                              // [cite: 263]
                                              final user =
                                                  FirebaseAuth // [cite: 263]
                                                      .instance
                                                      .currentUser; // [cite: 264]
                                              if (user != null && // [cite: 264]
                                                  taskId != null) {
                                                await FirebaseFirestore
                                                    .instance // [cite: 265]
                                                    .collection(
                                                        'users') // [cite: 265]
                                                    .doc(
                                                        user.uid) // [cite: 266]
                                                    .collection(// [cite: 266]
                                                        'scheduledTasks') // [cite: 267]
                                                    .doc(taskId) // [cite: 267]
                                                    .delete(); // [cite: 268]
                                                dev.log(
                                                    // [cite: 269]
                                                    "Task deleted successfully from Firestore.",
                                                    name: "SchedulerCard");
                                                // No need to manually update state, StreamProvider will do it. [cite: 270]
                                                // **FIX:** Removed mounted check
                                                ScaffoldMessenger.of(
                                                    // [cite: 271]
                                                    context).showSnackBar(
                                                  const SnackBar(
                                                      // [cite: 272]
                                                      content: // [cite: 272]
                                                          Text(
                                                              "Task deleted."), // [cite: 273]
                                                      duration: // [cite: 273]
                                                          Duration(
                                                              seconds:
                                                                  2)), // [cite: 274]
                                                );
                                              } else {
                                                // [cite: 275]
                                                throw Exception(// [cite: 275]
                                                    "User not logged in or Task ID missing."); // [cite: 276]
                                              } // [cite: 277]
                                            } catch (e) {
                                              // [cite: 277]
                                              dev.log(
                                                  // [cite: 277]
                                                  'Error deleting task from Firestore: $e',
                                                  name:
                                                      "SchedulerCard"); // [cite: 278]
                                              // **FIX:** Removed mounted check [cite: 279]
                                              ScaffoldMessenger.of(
                                                      context) // [cite: 279]
                                                  .showSnackBar(
                                                // [cite: 280]
                                                SnackBar(
                                                    // [cite: 280]
                                                    content: Text(// [cite: 281]
                                                        'Error deleting task: $e')), // [cite: 282]
                                              ); // [cite: 282]
                                            } // [cite: 283]
                                          }
                                        },
                                ), // [cite: 284]
                              ),
                            ],
                          ),
                        ); // [cite: 285]
                      }, // itemBuilder [cite: 286]
                    ), // ListView.builder
                  ), // SizedBox [cite: 286]
              ],
            ),
          ),
        ),
      ),
    ); // [cite: 287]
  }

  Widget buildSoilDataSection(BuildContext context) {
    // [cite: 287]
    // Assuming static values for now. [cite: 287]
    // Replace with provider data if dynamic. [cite: 288]
    String soilHumidity = "20%"; // [cite: 288]
    String soilMoisture = "30%"; // [cite: 289]

    return Column(// [cite: 290]
        children: [
      Padding(
        // [cite: 290]
        padding: const EdgeInsets.only(
            // [cite: 290]
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 8.0),
        child: Row(
          // [cite: 290]
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // [cite: 290]
          children: <Widget>[
            // [cite: 291]
            Text('Soil Data', // [cite: 291]
                style: TextStyle(
                    // [cite: 291]
                    fontSize: 18, // Adjusted size [cite: 291]
                    fontFamily: 'Poppins', // [cite: 291]
                    fontWeight: FontWeight.w600, // [cite: 292]
                    color: Colors.blueGrey[700])), // [cite: 292]
            ElevatedButton(
              // [cite: 292]
              // Use ElevatedButton [cite: 292]
              style: ElevatedButton.styleFrom(
                // [cite: 292]
                padding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4), // [cite: 292]
                textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Poppins'), // [cite: 293]
                // Add more styling if needed
              ),
              onPressed: () {
                // [cite: 293]
                Navigator.push(
                  // [cite: 294]
                  context, // [cite: 294]
                  MaterialPageRoute(
                      builder: (context) => // [cite: 294]
                          SensorDataCharts()), // Navigate to charts page [cite: 294]
                ); // [cite: 295]
              }, // [cite: 296]
              child: const Text('View Data'), // [cite: 296]
            ),
          ],
        ),
      ),
      Padding(
        // [cite: 296]
        // Add padding around the Row
        padding: const EdgeInsets.symmetric(
            horizontal: 13.0, vertical: 8.0), // [cite: 296]
        child: Row(
          // [cite: 296]
          children: <Widget>[
            // [cite: 297]
            Expanded(
              // [cite: 297]
              // Humidity Card [cite: 297]
              child: Container(
                // [cite: 297]
                height: 100, // Give cards a fixed height
                decoration: BoxDecoration(
                  // [cite: 298]
                  gradient: LinearGradient(
                    // [cite: 298]
                    begin: Alignment.topLeft, // [cite: 298]
                    end: Alignment.bottomRight, // [cite: 299]
                    colors: [
                      Colors.orange.shade300, // Changed colors [cite: 299]
                      Colors.orange.shade500, // [cite: 299]
                    ], // [cite: 300]
                  ),
                  borderRadius: // [cite: 300]
                      BorderRadius.circular(15), // Adjusted radius [cite: 300]
                  boxShadow: [
                    // [cite: 300]
                    BoxShadow(
                      // [cite: 301]
                      color: Colors.orange // [cite: 301]
                          .withOpacity(0.3), // Changed color [cite: 301]
                      blurRadius: 8, // Adjusted blur [cite: 302]
                      offset: Offset(0, 2), // Adjusted offset [cite: 302]
                    ),
                  ],
                ),
                child: Padding(
                  // [cite: 303]
                  padding: const EdgeInsets.all(12.0), // [cite: 303]
                  child: Column(
                    // [cite: 303]
                    mainAxisAlignment: MainAxisAlignment.center, // [cite: 304]
                    children: <Widget>[
                      Text(
                        // [cite: 304]
                        // Humidity Value [cite: 304]
                        soilHumidity, // [cite: 305]
                        style: const TextStyle(
                            // [cite: 305]
                            fontFamily: 'Poppins', // [cite: 305]
                            fontSize: 22, // [cite: 305]
                            fontWeight: FontWeight.bold, // [cite: 306]
                            color: Colors.white), // [cite: 306]
                      ),
                      const SizedBox(height: 5), // [cite: 306]
                      const Text(
                        // [cite: 307]
                        // Label [cite: 307]
                        'Soil Humidity', // [cite: 307]
                        textAlign: TextAlign.center, // [cite: 307]
                        style: TextStyle(
                            // [cite: 308]
                            fontFamily: 'Poppins', // [cite: 308]
                            color: Colors.white70, // [cite: 308]
                            fontSize: 14), // [cite: 309]
                      ),
                    ],
                  ),
                ),
              ), // [cite: 310]
            ), // [cite: 310]
            const SizedBox(width: 10), // [cite: 310]
            Expanded(
              // [cite: 310]
              // Moisture Card [cite: 310]
              child: Container(
                // [cite: 310]
                height: 100, // Give cards a fixed height [cite: 311]
                decoration: BoxDecoration(
                    // [cite: 311]
                    gradient: LinearGradient(
                      // [cite: 311]
                      begin: Alignment.topLeft, // [cite: 312]
                      end: Alignment.bottomRight, // [cite: 312]
                      colors: [
                        Colors.teal.shade300, // Changed colors [cite: 312]
                        Colors.teal.shade500, // [cite: 313]
                      ],
                    ),
                    borderRadius: BorderRadius.circular(// [cite: 313]
                        15), // Adjusted radius [cite: 314]
                    boxShadow: [
                      // [cite: 314]
                      BoxShadow(
                        // [cite: 314]
                        color: Colors.teal // [cite: 315]
                            .withOpacity(0.3), // Changed color [cite: 315]
                        blurRadius: 8, // Adjusted blur [cite: 315]
                        offset: Offset(0, 2), // [cite: 316]
                      )
                    ]),
                child: Padding(
                  // [cite: 316]
                  padding: const EdgeInsets.all(12.0), // [cite: 317]
                  child: Column(
                    // [cite: 317]
                    mainAxisAlignment: MainAxisAlignment.center, // [cite: 317]
                    children: <Widget>[
                      Text(
                        // [cite: 317]
                        // Moisture Value [cite: 318]
                        soilMoisture, // [cite: 318]
                        style: const TextStyle(
                            // [cite: 318]
                            fontFamily: 'Poppins', // [cite: 319]
                            fontSize: 22, // [cite: 319]
                            fontWeight: FontWeight.bold, // [cite: 319]
                            color: Colors.white), // [cite: 320]
                      ),
                      const SizedBox(height: 5), // [cite: 320]
                      const Text(
                        // [cite: 320]
                        // Label [cite: 321]
                        'Soil Moisture', // [cite: 321]
                        textAlign: TextAlign.center, // [cite: 321]
                        style: TextStyle(
                            // [cite: 321]
                            fontFamily: 'Poppins', // [cite: 322]
                            color: Colors.white70, // [cite: 322]
                            fontSize: 14), // [cite: 322]
                      ),
                    ], // [cite: 323]
                  ),
                ),
              ),
            ),
          ],
        ),
      ), // [cite: 323]
      const Divider(indent: 16, endIndent: 16, height: 24), // [cite: 324]
    ]); // Add divider [cite: 324]
  } // [cite: 325]

  Widget buildSchemesSection(BuildContext context) {
    // [cite: 325]
    // Load schemes from the static JSON string
    final List<dynamic> schemes = // [cite: 325]
        json.decode(agricultureSchemesJson); // [cite: 325]

    if (schemes.isEmpty) return const SizedBox.shrink(); // [cite: 326]

    return Column(
      // [cite: 327]
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align title left [cite: 327]
      children: [
        Padding(
          // [cite: 327]
          padding: const EdgeInsets.only(
              // [cite: 327]
              left: 16.0, // [cite: 327]
              right: 16.0, // [cite: 327]
              top: 8.0, // [cite: 328]
              bottom: 12.0), // Adjust padding [cite: 328]
          child: // [cite: 328]
              Text("Government Schemes", // Changed title slightly [cite: 328]
                  style: TextStyle(
                      // [cite: 328]
                      fontSize: 18, // Adjusted size [cite: 329]
                      fontWeight: FontWeight.w600, // [cite: 329]
                      color: Colors.blueGrey[700], // Adjusted color [cite: 329]
                      fontFamily: 'Poppins')), // [cite: 330]
        ),
        // Use ListView.builder for performance if list can be long
        // Since it's nested in a ListView, set physics and shrinkWrap
        ListView.builder(
          // [cite: 330]
          shrinkWrap: true, // Important in nested list [cite: 330]
          physics: // [cite: 330]
              const NeverScrollableScrollPhysics(), // Disable scrolling for this list [cite: 331]
          itemCount: schemes.length, // [cite: 331]
          itemBuilder: (context, index) {
            // [cite: 331]
            final scheme = schemes[index]; // [cite: 331]
            // Added null checks for safety [cite: 332]
            final imageUrl = scheme['imageUrl'] as String?; // [cite: 332]
            final schemeName = // [cite: 333]
                scheme['schemeName'] as String? ?? 'N/A'; // [cite: 333]
            final description =
                scheme['description'] as String? ?? // [cite: 334]
                    'No description'; // [cite: 335]
            final benefits = // [cite: 335]
                scheme['benefits'] as String? ?? 'N/A'; // [cite: 335]
            final eligibility = // [cite: 336]
                scheme['eligibility'] as String? ?? 'N/A'; // [cite: 336]
            final website = scheme['website'] as String? ?? ''; // [cite: 337]

            return TweenAnimationBuilder<double>(
              // [cite: 338]
              // Keep animation [cite: 338]
              tween: Tween<double>(begin: 0.0, end: 1.0), // [cite: 338]
              duration: const Duration(
                  // [cite: 338]
                  milliseconds: 600), // Adjusted duration [cite: 338]
              curve: Curves.easeOut, // Add curve [cite: 339]
              builder: (context, opacity, child) {
                // [cite: 339]
                return Opacity(
                  // [cite: 339]
                  opacity: opacity, // [cite: 340]
                  child: Container(
                    // [cite: 340]
                    // Scheme Card [cite: 340]
                    margin: const EdgeInsets.only(
                        // [cite: 340]
                        left: 13.0, // [cite: 341]
                        right: 13.0, // [cite: 341]
                        bottom: 15.0), // Adjusted margin [cite: 341]
                    decoration: BoxDecoration(
                      // [cite: 341]
                      // Card decoration [cite: 342]
                      color: Colors.white, // Use white background [cite: 342]
                      borderRadius: BorderRadius.circular(10), // [cite: 342]
                      boxShadow: [
                        // [cite: 342]
                        // Softer shadow [cite: 343]
                        BoxShadow(
                            color: Colors.grey.withOpacity(// [cite: 343]
                                0.2), // Adjusted shadow [cite: 344]
                            spreadRadius: 1, // [cite: 344]
                            blurRadius: 5, // [cite: 344]
                            offset: Offset(0, 2)), // [cite: 345]
                      ],
                    ),
                    clipBehavior: // [cite: 345]
                        Clip.antiAlias, // Clip image to rounded corners [cite: 345]
                    child: Column(
                      // [cite: 346]
                      // Use Column layout [cite: 346]
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // [cite: 346]
                      children: <Widget>[
                        // --- Image --- [cite: 347]
                        if (imageUrl != // [cite: 347]
                            null) // Check for null imageUrl [cite: 347]
                          Image.network(
                            // [cite: 348]
                            imageUrl, // [cite: 348]
                            width: double.infinity, // Full width [cite: 348]
                            height: 150, // Fixed height [cite: 349]
                            fit: BoxFit.cover, // Cover the area [cite: 349]
                            // Add loading/error builders for Image.network [cite: 349]
                            loadingBuilder: (context, child, loadingProgress) {
                              // [cite: 350]
                              if (loadingProgress == null)
                                return child; // [cite: 350]
                              return Container(
                                // [cite: 351]
                                height: 150, // [cite: 351]
                                width: double.infinity, // [cite: 351]
                                color: Colors.grey[200], // [cite: 352]
                                child: Center(
                                  // [cite: 352]
                                  child: CircularProgressIndicator(
                                    // [cite: 352]
                                    value: loadingProgress
                                                .expectedTotalBytes != // [cite: 353]
                                            null
                                        ? loadingProgress // [cite: 353]
                                                .cumulativeBytesLoaded / // [cite: 354]
                                            loadingProgress.expectedTotalBytes!
                                        : null, // [cite: 355]
                                  ),
                                ),
                              ); // [cite: 356]
                            }, // [cite: 357]
                            errorBuilder: (context, error, stackTrace) {
                              // [cite: 357]
                              return Container(
                                // [cite: 357]
                                height: 150, // [cite: 357]
                                width: double.infinity, // [cite: 358]
                                color: Colors.grey[300], // [cite: 358]
                                child: Center(
                                    // [cite: 358]
                                    child: Icon(
                                        Icons.broken_image, // [cite: 359]
                                        color:
                                            Colors.grey[500])), // [cite: 359]
                              ); // [cite: 360]
                            },
                          )
                        else // Placeholder if no image URL [cite: 360]
                          Container(
                            // [cite: 360]
                            width: double.infinity, // [cite: 361]
                            height: 100, // [cite: 361]
                            decoration: BoxDecoration(
                              // [cite: 362]
                              color: Colors.blueGrey[// [cite: 362]
                                  50], // Lighter placeholder [cite: 363]
                              // No need for separate border radius here due to clipBehavior on parent [cite: 363]
                            ),
                            child: Center(
                                // [cite: 364]
                                child: Icon(
                                    Icons.image_not_supported, // [cite: 364]
                                    color:
                                        Colors.blueGrey[200])), // [cite: 364]
                          ), // [cite: 365]
                        // --- Content Area ---
                        Padding(
                          // [cite: 365]
                          // Add padding for text content
                          padding: const EdgeInsets.all(// [cite: 366]
                              12.0), // Combined padding [cite: 366]
                          child: Column(
                            // [cite: 366]
                            // Column for text details [cite: 367]
                            crossAxisAlignment: // [cite: 367]
                                CrossAxisAlignment.start, // [cite: 367]
                            children: <Widget>[
                              // [cite: 368]
                              Text(
                                // [cite: 368]
                                // Scheme Name [cite: 368]
                                schemeName, // [cite: 369]
                                style: TextStyle(
                                    // [cite: 369]
                                    color: Colors.blueGrey[
                                        800], // Darker text [cite: 370]
                                    fontWeight: FontWeight.bold, // [cite: 370]
                                    fontSize: 17, // Increase size [cite: 370]
                                    fontFamily: 'Poppins'), // [cite: 371]
                              ),
                              const SizedBox(height: 8), // [cite: 371]
                              Text(
                                // [cite: 372]
                                // Description [cite: 372]
                                description, // [cite: 372]
                                style: TextStyle(
                                    // [cite: 373]
                                    color: Colors // [cite: 374]
                                            .blueGrey[
                                        600], // Slightly lighter text [cite: 374]
                                    fontSize: 14, // [cite: 374]
                                    fontFamily: 'Poppins'), // [cite: 375]
                              ),
                              const Divider(
                                  // [cite: 375]
                                  height: 16,
                                  thickness: 1), // Add divider [cite: 376]
                              _buildSchemeDetailRow(
                                  // [cite: 376]
                                  Icons.star_border,
                                  'Benefits:',
                                  benefits), // [cite: 376]
                              const SizedBox(height: 6), // [cite: 377]
                              _buildSchemeDetailRow(
                                  Icons.check_circle_outline, // [cite: 377]
                                  'Eligibility:',
                                  eligibility), // [cite: 377]
                              const SizedBox(height: 6), // [cite: 378]
                              // Clickable Website Link
                              if (website.isNotEmpty) // [cite: 378]
                                InkWell(
                                  // [cite: 379]
                                  onTap: () => _launchUrl(// [cite: 379]
                                      website), // Use launch URL function
                                  child: Row(
                                    // [cite: 380]
                                    children: [
                                      Icon(Icons.language, // [cite: 381]
                                          size: 16, // [cite: 381]
                                          color: Colors.lightBlue
                                              .shade700), // [cite: 381]
                                      const SizedBox(width: 4), // [cite: 382]
                                      Flexible(
                                        // [cite: 382]
                                        // Allow text to wrap
                                        child: Text(
                                          // [cite: 383]
                                          'Visit Website', // Clearer text [cite: 383]
                                          style: TextStyle(
                                              // [cite: 384]
                                              color: Colors
                                                  .lightBlue // [cite: 385]
                                                  .shade700, // Link color [cite: 385]
                                              fontFamily: // [cite: 386]
                                                  'Poppins', // [cite: 386]
                                              fontSize: 14, // [cite: 387]
                                              decoration:
                                                  TextDecoration // [cite: 387]
                                                      .underline, // Underline link [cite: 388]
                                              decorationColor: // [cite: 388]
                                                  Colors.lightBlue
                                                      .shade700), // [cite: 389]
                                        ),
                                      ), // [cite: 390]
                                    ],
                                  ),
                                ) // [cite: 391]
                              else // Show N/A if no website [cite: 391]
                                _buildSchemeDetailRow(
                                    // [cite: 391]
                                    Icons.language,
                                    'Website:',
                                    'N/A'), // [cite: 392]
                            ],
                          ),
                        ), // [cite: 393]
                      ],
                    ),
                  ),
                ); // [cite: 393]
              }, // builder [cite: 394]
            ); // TweenAnimationBuilder [cite: 395]
          }, // itemBuilder
        ), // ListView.builder [cite: 395]
      ],
    ); // Column for Schemes [cite: 396]
  }

  // Helper for scheme detail rows
  Widget _buildSchemeDetailRow(IconData icon, String label, String value) {
    // [cite: 396]
    return Row(
      // [cite: 396]
      crossAxisAlignment: CrossAxisAlignment.start, // [cite: 396]
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey[400]), // [cite: 396]
        const SizedBox(width: 6), // [cite: 396]
        Text(
          // [cite: 396]
          label, // [cite: 396]
          style: TextStyle(
              // [cite: 396]
              color: Colors.blueGrey[700], // [cite: 397]
              fontWeight: FontWeight.w600, // [cite: 397]
              fontSize: 14, // [cite: 397]
              fontFamily: 'Poppins'), // [cite: 397]
        ),
        const SizedBox(width: 4), // [cite: 397]
        Expanded(
          // [cite: 397]
          // Allow value text to wrap
          child: Text(
            // [cite: 398]
            value, // [cite: 398]
            style: TextStyle(
                // [cite: 398]
                color: Colors.blueGrey[600], // [cite: 398]
                fontSize: 14, // [cite: 398]
                fontFamily: 'Poppins' // [cite: 399]
                ),
          ),
        ),
      ],
    ); // [cite: 399]
  } // [cite: 400]
} // End of CropDetailsPage [cite: 400]