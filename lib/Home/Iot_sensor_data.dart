import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_database/firebase_database.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final database = FirebaseDatabase.instance.ref();
  List<SoilData> _humidityData = [];
  List<SoilData> _soilMoistureData = [];
  List<SoilData> _temperatureData = [];

  @override
  void initState() {
    super.initState();
    _readData();
  }

  void _readData() {
    database.child('sensor').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        try {
          final timestamp = DateTime.now();

          final humidityPoint = SoilData(
            timestamp: timestamp,
            value: (data['humidity'] as num).toDouble(),
          );
          final soilMoisturePoint = SoilData(
            timestamp: timestamp,
            value: (data['soil_moisture'] as num).toDouble(),
          );
          final temperaturePoint = SoilData(
            timestamp: timestamp,
            value: (data['temperature'] as num).toDouble(),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _humidityData.add(humidityPoint);
                _soilMoistureData.add(soilMoisturePoint);
                _temperatureData.add(temperaturePoint);
                if (_humidityData.length > 100) {
                  _humidityData.removeAt(0);
                }
                if (_soilMoistureData.length > 100) {
                  _soilMoistureData.removeAt(0);
                }
                if (_temperatureData.length > 100) {
                  _temperatureData.removeAt(0);
                }
              });
            }
          });
        } catch (e) {
          print('Error processing data: $e');
        }
      } else {
        print('No data found under "sensor".');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _humidityData = [];
              _soilMoistureData = [];
              _temperatureData = [];
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PreviousData()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildChart('Humidity', _humidityData),
            _buildChart('Soil Moisture', _soilMoistureData),
            _buildChart('Temperature', _temperatureData),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(String title, List<SoilData> data) {
    final latestValue =
        data.isNotEmpty ? data.last.value.toStringAsFixed(2) : 'N/A';
    return Column(
      children: [
        Text(
          '$title: $latestValue',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SfCartesianChart(
          plotAreaBorderWidth: 2,
          plotAreaBorderColor: Colors.grey,
          series: <LineSeries<SoilData, DateTime>>[
            LineSeries<SoilData, DateTime>(
              dataSource: data,
              xValueMapper: (SoilData soilData, _) => soilData.timestamp,
              yValueMapper: (SoilData soilData, _) => soilData.value,
            ),
          ],
          primaryXAxis: DateTimeAxis(isVisible: true),
          primaryYAxis: NumericAxis(isVisible: true),
        ),
      ],
    );
  }
}

class SoilData {
  final DateTime timestamp;
  final double value;

  SoilData({required this.timestamp, required this.value});
}

class PreviousData extends StatelessWidget {
  const PreviousData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Data')),
      body: const Center(child: Text('Previous Data')),
    );
  }
}
