import 'dart:async';

import 'package:agriculture/Auth/AuthWrapper.dart';
import 'package:agriculture/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Initialize time zones first
  await _configureLocalTimeZone();
  try {
    await _configureLocalNotifications();

    // other async operations
  } catch (e) {
    print('Error during initialization: $e');
    //Handle the error, perhaps by showing an error screen.
  }
  runApp(const AgriIoTApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set your timezone
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _configureLocalNotifications() async {
  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a notification channel (Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'weather_alert_channel', // id
      'Weather Alerts', // title
      description: 'Weather alerts for farmers', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request notification permissions
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permissions granted.');
      } else {
        print('Notification permissions denied.');
        // Handle permission denial gracefully (e.g., show a message).
      }
    } else {
      print('Notification permission status: $status');
    }
  } catch (e) {
    print('Error configuring notifications: $e');
  }
}

class AgriIoTApp extends StatelessWidget {
  const AgriIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriIoT',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('isLoggedIn') ?? false) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LanguageSelectionPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 238, 238),
      body: Center(
          child: Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/ic_launcher.png',
              width: 100, // increased width
              height: 100, // increased height
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Farmer Help App',
            style: TextStyle(
                fontFamily: AutofillHints.name,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
        ]),
      )),
    );
  }
}

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguageCode = 'en'; // Default to English

  final List<String> _languageCodes = ['en', 'hi', 'te', 'bn', 'ur'];
  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'te': 'తెలుగు',
    'bn': 'বাংলা',
    'ur': 'اردو',
  };

  Future<void> _maybeShowLanguageSelection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('language')) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingWrapper()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _maybeShowLanguageSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Choose your preferred language:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _languageCodes.map((languageCode) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguageCode = languageCode;
                    });
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: _selectedLanguageCode == languageCode
                            ? Colors.green
                            : Colors.grey,
                        width: _selectedLanguageCode == languageCode ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Radio<String>(
                            value: languageCode,
                            groupValue: _selectedLanguageCode,
                            onChanged: (String? value) {
                              setState(() {
                                if (value != null) {
                                  _selectedLanguageCode = value;
                                }
                              });
                            },
                          ),
                          Text(_languageNames[languageCode]!),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('language', _selectedLanguageCode);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnboardingWrapper()),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('firstLaunch') ?? true;
    setState(() {
      _showOnboarding = isFirstLaunch;
    });
    if (isFirstLaunch) {
      await prefs.setBool('firstLaunch', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showOnboarding ? const OnboardingScreen() : const AuthWrapper();
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const <Widget>[
                  OnboardingPage(
                    title: 'Welcome to AgriIoT',
                    description: 'Get real-time data about your crops.',
                    image: Icons.grass,
                  ),
                  OnboardingPage(
                    title: 'Detect Crop Diseases',
                    description: 'Identify and treat diseases early.',
                    image: Icons.healing,
                  ),
                  OnboardingPage(
                    title: 'Learn and Grow',
                    description: 'Access educational resources for farmers.',
                    image: Icons.school,
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _pageController,
              count: 3,
              effect: const WormEffect(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                }
              },
              child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData image;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(image, size: 100, color: Colors.green),
        const SizedBox(height: 20),
        Text(title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(description, textAlign: TextAlign.center),
      ],
    );
  }
}

// AuthWrapper, LoginPage, SignupPage, HomePage, CropDetailsPage, etc. remain the same.

