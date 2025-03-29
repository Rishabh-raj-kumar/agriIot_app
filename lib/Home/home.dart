import 'package:agriculture/Disease/Disease_detection.dart';
import 'package:agriculture/Home/Scheduler.dart';
import 'package:agriculture/Home/SensorData.dart';
import 'package:agriculture/Multilanguage/Applocal.dart';
import 'package:agriculture/Settings.dart';
import 'package:agriculture/buisness_market/b2b.dart';
import 'package:agriculture/course/Course.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  double _soilMoisture = 65.0;
  double _temperature = 28.0;
  double _humidity = 70.0;
  String _weatherDescription = '';
  String _weatherdata = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _taskDescription = '';
  List<Map<String, dynamic>> _scheduledTasks = [];

  Map<String, dynamic> weatherData = {};

  String _languageCode = 'en';

  Future<void> _loadLanguage() async {
    _languageCode = await getLanguageCode();
    setState(() {}); //Rebuild the widget when language code is fetched.
  }

  Future<void> _loadScheduledTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('scheduledTasks');
    if (tasksJson != null) {
      setState(() {
        _scheduledTasks = (json.decode(tasksJson) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });
      setState(() {
        _taskDescription = "Hello";
      });
    }
  }

  Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  static const List<Widget> _widgetOptions = <Widget>[
    CropDetailsPage(),
    DiseaseDetectionPage(),
    CoursePage(),
    MarketplaceScreen(),
    SettingPage()
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _fetchWeatherData();
    _startWeatherCheck();
    _loadScheduledTasks();
  }

  Future<void> _fetchWeatherData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedWeatherData = prefs.getString('weatherData') ?? '';
      if (storedWeatherData.isNotEmpty) {
        weatherData = json.decode(storedWeatherData);
        setState(() {
          _weatherDescription = weatherData['weather'][0]['description'];
          _weatherdata = weatherData['weather'][0]['name'];
        });
      } else {
        Location location = Location();
        bool serviceEnabled;
        PermissionStatus permissionGranted;
        LocationData locationData;

        serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            return;
          }
        }

        permissionGranted = await location.hasPermission();
        if (permissionGranted == PermissionStatus.denied) {
          permissionGranted = await location.requestPermission();
          if (permissionGranted != PermissionStatus.granted) {
            return;
          }
        }

        locationData = await location.getLocation();
        final lat = locationData.latitude;
        final lon = locationData.longitude;

        final response = await http.get(Uri.parse(
            'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherApiKey')); // Replace with your API key

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print(response.body);
          weatherData = data;
          setState(() {
            _weatherDescription = data['weather'][0]['description'];
            _weatherdata = data['weather'][0]['name'];
          });
          prefs.setString('weatherData', json.encode(data));
        } else {
          print('Failed to fetch weather data: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error fetching weather data: $e');
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
    Locale myLocale = Locale(_languageCode);
    AppLocalizations localizations = AppLocalizations(myLocale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriIoT'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.healing),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildCropDetails() {
    return ListView(
      children: <Widget>[
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.cloud, color: Colors.blue, size: 50),
                    SizedBox(width: 10),
                    Text('Weather Report',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
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
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Icon(Icons.water, color: Colors.blue),
                        Text('Humidity'),
                        Text('${weatherData['main']?['humidity'] ?? "8 "} %',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Icon(Icons.air, color: Colors.grey),
                        Text('Wind Speed'),
                        Text('${weatherData['wind']?['speed'] ?? "2 "} m/s',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SchedulerPage()),
                    );
                  },
                  child: const Text('Add Schedule'),
                ),
                const Divider(height: 20, thickness: 1),
                if (_taskDescription.isEmpty)
                  Text(
                    'No task description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  Column(
                    // Replaced Expanded with Column
                    children: _scheduledTasks.map((task) {
                      return ListTile(
                        title: Text(task['description']),
                        subtitle: Text(
                            '${DateFormat('dd MMM yyyy').format(DateTime.parse(task['date']))} ${task['time']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final tasksJson = prefs.getString('scheduledTasks');
                            final tasks = (json.decode(tasksJson!) as List)
                                .where((element) =>
                                    element['description'] !=
                                    task['description'])
                                .toList();
                            await prefs.setString(
                                'scheduledTasks', json.encode(tasks));
                            setState(() {
                              _scheduledTasks = List<Map<String, dynamic>>.from(
                                  tasks.cast<Map<String, dynamic>>());
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                SensorDataCharts(),
              ],
            ),
          ),
        ),
      ],
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Tips for Small Scale Farmers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
