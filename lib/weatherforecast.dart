import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WeatherForecastService {
  final String apiKey;

  WeatherForecastService(this.apiKey);

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching weather data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getForecast() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['list']);
      } else {
        throw Exception(
            'Failed to fetch forecast data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forecast data: $e');
    }
  }
}

class WeatherForecastWidget extends StatefulWidget {
  final String apiKey;

  const WeatherForecastWidget({super.key, required this.apiKey});

  @override
  _WeatherForecastWidgetState createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget> {
  late WeatherForecastService _weatherService;
  Map<String, dynamic> _currentWeather = {};
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _weatherService = WeatherForecastService(widget.apiKey);
    _initializeNotifications();
    _fetchWeatherData();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Replace with your app icon
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final currentWeather = await _weatherService.getCurrentWeather();
      final forecast = await _weatherService.getForecast();
      setState(() {
        _currentWeather = currentWeather;
        _forecast = forecast;
        _isLoading = false;
        _showNotificationIfRainOrCloudy();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _refreshWeatherData() async {
    _fetchWeatherData();
  }

  String _getRainSuggestion() {
    if (_forecast.any((element) =>
        element['weather'][0]['main'].toString().toLowerCase() == 'rain')) {
      final rainForecast = _forecast.firstWhere((element) =>
          element['weather'][0]['main'].toString().toLowerCase() == 'rain');
      final rainTime =
          DateTime.fromMillisecondsSinceEpoch(rainForecast['dt'] * 1000);
      return 'Rain is expected on ${DateFormat('EEE, MMM d, h:mm a').format(rainTime)}. Prepare accordingly.';
    } else {
      return 'No rain is expected in the next 5 days.';
    }
  }

  String _getAgricultureTips() {
    final weatherDescription =
        _currentWeather['weather']?[0]['description']?.toLowerCase() ?? '';

    if (weatherDescription.contains('rain')) {
      return 'Prepare for potential waterlogging. Ensure proper drainage in fields.';
    } else if (weatherDescription.contains('clear') ||
        weatherDescription.contains('sunny')) {
      return 'Consider irrigating crops due to clear skies and potential for high evaporation.';
    } else {
      return 'Monitor crops closely for any signs of stress due to current weather conditions.';
    }
  }

  Future<void> _showNotificationIfRainOrCloudy() async {
    if (_forecast.any((element) =>
        element['weather'][0]['main'].toString().toLowerCase() == 'rain' ||
        element['weather'][0]['main'].toString().toLowerCase() == 'clouds')) {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'weather_alert',
        'Weather Alerts',
        channelDescription: 'Alerts for rain and cloudy weather',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Weather Alert',
        'Rain or cloudy weather expected soon!',
        notificationDetails,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshWeatherData,
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.lightBlue[300],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[100]!, Colors.blue[300]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Current Weather',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.thermostat, color: Colors.red),
                    SizedBox(width: 5),
                    Text('Temperature: ${_currentWeather['main']['temp']}°C',
                        style: TextStyle(color: Colors.grey[700]))
                  ]),
                  Row(children: [
                    Icon(Icons.water_drop, color: Colors.blue),
                    SizedBox(width: 5),
                    Text('Humidity: ${_currentWeather['main']['humidity']}%',
                        style: TextStyle(color: Colors.grey[700]))
                  ]),
                  Row(children: [
                    Icon(Icons.cloud, color: Colors.grey),
                    SizedBox(width: 5),
                    Text(
                        'Description: ${_currentWeather['weather'][0]['description']}',
                        style: TextStyle(color: Colors.grey[700]))
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_getRainSuggestion(), style: TextStyle(color: Colors.blue[100])),
          const SizedBox(height: 10),
          Text(_getAgricultureTips(),
              style: TextStyle(color: Colors.blue[100])),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue),
              SizedBox(width: 5),
              Text('5-Day Forecast:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey[800])),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _forecast.length > 5 ? 5 : _forecast.length,
              itemBuilder: (context, index) {
                final forecast = _forecast[index * 8];
                final date =
                    DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                final formattedDate = DateFormat('EEE').format(date);
                final iconUrl =
                    'http://openweathermap.org/img/w/${forecast['weather'][0]['icon']}.png';
                return Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(formattedDate,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey[800])),
                      const SizedBox(height: 8),
                      Image.network(iconUrl, height: 100, width: 100),
                      const SizedBox(height: 8),
                      Text('${forecast['main']['temp'].toStringAsFixed(0)}°C',
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyWeatherApp extends StatelessWidget {
  final String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherForecastWidget(apiKey: apiKey),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
