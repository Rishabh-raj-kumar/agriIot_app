import 'package:agriculture/Auth/AuthWrapper.dart';
import 'package:agriculture/firebase_options.dart';
import 'package:agriculture/locationPermission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Keep shared_preferences for other flags
import 'package:agriculture/Home/home.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:timezone/timezone.dart'
    as tz; // Import main for Onboarding/Language pages

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // State to track if SharedPreferences checks are done
  bool _prefsLoaded = false;
  // States from SharedPreferences
  bool _isFirstLaunch = true;
  String? _selectedLanguage; // Or use a default if no language saved

  @override
  void initState() {
    super.initState();
    _performInitialChecks();
  }

  Future<void> _performInitialChecks() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstLaunch = prefs.getBool('firstLaunch') ?? true;
    _selectedLanguage = prefs.getString('language');

    // Update state to indicate prefs are loaded
    setState(() {
      _prefsLoaded = true;
    });

    // No navigation here. Navigation happens in the build method
    // once Firebase state AND prefs state are ready.
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show loading while SharedPreferences are loading
    if (!_prefsLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Once SharedPreferences are loaded, listen to Firebase Auth state
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while Firebase Auth state is being determined
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Handle errors during auth state check (optional but good practice)
        if (snapshot.hasError) {
          print('Auth state stream error: ${snapshot.error}');
          // You might want to show an error screen here
          return Scaffold(
            body:
                Center(child: Text('Authentication error: ${snapshot.error}')),
          );
        }

        // 3. Firebase Auth state is determined (snapshot.connectionState is active)
        final User? user = snapshot.data;

        if (user != null) {
          // User is logged in via Firebase
          // If they were previously sent to language/onboarding, this stream
          // listener catches the login and routes them home correctly.
          print('User is logged in: ${user.uid}');
          return const HomePage(initialTask: []);
        } else {
          // User is NOT logged in via Firebase
          print('User is NOT logged in.');

          // Now check other initial flags from SharedPreferences
          if (_selectedLanguage == null) {
            // Language hasn't been selected yet
            print('Navigating to LanguageSelectionPage');
            return const PermissionHandlerWrapper();
          }

          if (_isFirstLaunch) {
            // Language selected, but it's the first launch (show onboarding)
            print('Navigating to OnboardingWrapper');
            // OnboardingWrapper needs to handle marking firstLaunch as false *after* onboarding is done
            // and then navigating to the next step (likely SignupPage or LoginPage)
            return const OnboardingWrapper();
          }

          // Not first launch, language selected, not logged in
          // Default: show the Login page
          print('Navigating to LoginPage');
          return const LoginPage();
        }
      },
    );
  }
}

// --- OnboardingWrapper ---
// Modify this to handle marking firstLaunch=false after OnboardingScreen
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  // No need for _showOnboarding state here, AuthWrapper decided to show this
  // Use this wrapper to manage the transition *after* onboarding is finished.

  Future<void> _onOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
    print('Marked firstLaunch as false.');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const SignupPage()), // Or LoginPage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget just wraps the OnboardingScreen
    // OnboardingScreen will call _onOnboardingComplete when done.
    return OnboardingScreen(onComplete: _onOnboardingComplete);
  }
}

// --- OnboardingScreen ---
// Add an onComplete callback
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete; // Callback to notify parent when done
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: const <Widget>[
              OnboardingPage(
                image: 'assets/images/Onboard_1.png',
              ),
              OnboardingPage(
                image: 'assets/images/Onboard_2.png',
              ),
              OnboardingPage(
                image: 'assets/images/Onboard_3.png',
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: <Widget>[
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const WormEffect(),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      } else {
                        // Onboarding finished, call the callback
                        widget.onComplete();
                      }
                    },
                    child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  const OnboardingPage({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// --- LanguageSelectionPage ---
// Remove the incorrect navigation from initState
class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  _LanguageSelectionPageState createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguageCode; // Default to English

  final List<String> _languageCodes = ['en', 'hi', 'te', 'bn', 'ur'];
  final Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'te': 'తెలుగు',
    'bn': 'বাংলা',
    'ur': 'اردো',
  };

  Future<void> _saveAndProceed() async {
    // This is triggered by the button press, not initState
    if (_selectedLanguageCode == null) {
      // Optionally show a snackbar if no language is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguageCode!);
    print('Saved language: $_selectedLanguageCode');

    // Navigate to the next screen after language selection.
    // Since AuthWrapper decided we needed a language, the next step
    // should be checking if it's the first launch (OnboardingWrapper)
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const OnboardingWrapper()), // Navigate to OnboardingWrapper
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // DO NOT CALL _saveAndProceed() here.
    // The user needs to select a language and press the button.
    // _saveAndProceed(); // <--- REMOVE THIS LINE
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        elevation: 1, // Subtle elevation
        backgroundColor: theme.colorScheme.surface, // Use theme surface color
        foregroundColor: theme.colorScheme.onSurface, // Use theme text color
      ),
      body: SafeArea(
        // Ensure content avoids notches/status bars
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Stretch children horizontally
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Text(
                'Choose your preferred language', // More direct instruction
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600, // Bolder title
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              // Allow ListView to take available space
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _languageCodes.length,
                itemBuilder: (context, index) {
                  final languageCode = _languageCodes[index];
                  final languageName = _languageNames[languageCode]!;
                  final isSelected = _selectedLanguageCode == languageCode;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0), // Spacing between items
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact(); // Subtle feedback on tap
                        setState(() {
                          _selectedLanguageCode = languageCode;
                        });
                      },
                      borderRadius:
                          BorderRadius.circular(12.0), // Match container radius
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 14.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(
                                  0.10) // Highlight color for selected
                              : theme.colorScheme.surfaceVariant.withOpacity(
                                  0.5), // Subtle background for others
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme
                                    .primary // Primary color border for selected
                                : Colors
                                    .transparent, // No border for unselected
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          // Optional: Add subtle shadow
                          // boxShadow: isSelected ? [
                          //  BoxShadow(
                          //   color: theme.colorScheme.primary.withOpacity(0.2),
                          //   blurRadius: 4,
                          //   offset: Offset(0, 2),
                          //  )
                          // ] : [],
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                languageName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            if (isSelected) // Show check icon only if selected
                              Icon(
                                Icons.check_circle, // Filled check circle
                                color: theme.colorScheme.primary,
                                size: 22,
                              )
                            else
                              // Optional: Placeholder for alignment or different icon
                              const SizedBox(width: 22), // Maintain space
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // --- Confirmation Button Area ---
            Padding(
              padding: const EdgeInsets.all(16.0)
                  .copyWith(bottom: 24.0), // More bottom padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.primary, // Use theme primary color
                  foregroundColor:
                      theme.colorScheme.onPrimary, // Text color on primary
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0), // Consistent radius
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  // Disable button if no language is selected
                  disabledBackgroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.12),
                  disabledForegroundColor:
                      theme.colorScheme.onSurface.withOpacity(0.38),
                ),
                // Disable onPressed if nothing is selected
                onPressed: _selectedLanguageCode != null
                    ? _saveAndProceed
                    : null, // Trigger on button press
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

Future<void> _configureLocalTimeZone() async {
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set your timezone
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- Only call ONCE here

  tz.initializeTimeZones(); // Initialize time zones
  await _configureLocalTimeZone();

  // Initialize Firebase *before* any widget tries to access it
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Depending on how critical Firebase is, you might show an error screen
    // and prevent the app from running further.
    // For now, we'll let it try to run, but AuthWrapper might show errors.
  }

  // Configure local notifications after ensureInitialized
  try {
    await _configureLocalNotifications();
    print('Local Notifications configured');
  } catch (e) {
    print('Error configuring local notifications: $e');
    //Handle the error for notifications if needed, it might not be critical for app startup.
  }

  runApp(const AgriIoTApp());
}

// Keep _configureLocalTimeZone and _configureLocalNotifications functions as they are.
// Keep AgriIoTApp StatelessWidget as it is, but change the home property.

class AgriIoTApp extends StatelessWidget {
  const AgriIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgriIoT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      // The initial screen is now the AuthWrapper
      home: const AuthWrapper(),
    );
  }
}
