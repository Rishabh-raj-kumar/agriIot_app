import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorDataCharts extends StatefulWidget {
  const SensorDataCharts({super.key});

  @override
  _SensorDataChartsState createState() => _SensorDataChartsState();
}

class _SensorDataChartsState extends State<SensorDataCharts> {
  late List<SensorData> _soilMoistureData;
  late List<SensorData> _humidityData;
  late TooltipBehavior _tooltipBehavior;
  String _irrigationAdvice = '';

  @override
  void initState() {
    super.initState();
    _soilMoistureData = getSoilMoistureData();
    _humidityData = getHumidityData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _analyzeSensorData();
  }

  List<SensorData> getSoilMoistureData() {
    final List<SensorData> chartData = [
      SensorData('00:00', 10),
      SensorData('03:00', 15),
      SensorData('06:00', 25),
      SensorData('09:00', 30),
      SensorData('12:00', 35),
      SensorData('15:00', 35),
      SensorData('18:00', 20),
      SensorData('21:00', 18),
      SensorData('2400', 22),
    ];
    return chartData;
  }

  List<SensorData> getHumidityData() {
    final List<SensorData> chartData = [
      SensorData('00:00', 30),
      SensorData('03:00', 35),
      SensorData('06:00', 40),
      SensorData('09:00', 45),
      SensorData('12:00', 50),
      SensorData('15:00', 58),
      SensorData('18:00', 52),
      SensorData('21:00', 48),
      SensorData('24:00', 42),
    ];
    return chartData;
  }

  void _analyzeSensorData() {
    double avgSoilMoisture =
        _soilMoistureData.map((data) => data.value).reduce((a, b) => a + b) /
            _soilMoistureData.length;
    double avgHumidity =
        _humidityData.map((data) => data.value).reduce((a, b) => a + b) /
            _humidityData.length;

    if (avgSoilMoisture < 50 && avgHumidity < 60) {
      _irrigationAdvice =
          'Soil moisture is low (${avgSoilMoisture.toStringAsFixed(2)}%) and humidity is low (${avgHumidity.toStringAsFixed(2)}%). Irrigation is recommended.';
    } else if (avgSoilMoisture < 50) {
      _irrigationAdvice =
          'Soil moisture is low (${avgSoilMoisture.toStringAsFixed(2)}%). Irrigation may be needed soon.';
    } else if (avgHumidity < 60) {
      _irrigationAdvice =
          'Humidity is low (${avgHumidity.toStringAsFixed(2)}%). Consider irrigation if soil is also dry.';
    } else {
      _irrigationAdvice =
          'Soil moisture (${avgSoilMoisture.toStringAsFixed(2)}%) and humidity (${avgHumidity.toStringAsFixed(2)}%) are within acceptable ranges. Monitor closely.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Sensor Data'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
        ),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
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
                    color: Colors.blue[400]!,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                width: 300,
                height: 250,
                child: SfCartesianChart(
                  title: const ChartTitle(
                      text: 'Soil Moisture (20%)',
                      textStyle: TextStyle(color: Colors.white)),
                  primaryXAxis: CategoryAxis(),
                  tooltipBehavior: _tooltipBehavior,
                  series: <LineSeries<SensorData, String>>[
                    LineSeries<SensorData, String>(
                      pointColorMapper: (SensorData data, _) => Colors.white,
                      color: Colors.blue[100]!,
                      dataSource: _soilMoistureData,
                      xValueMapper: (SensorData data, _) => data.time,
                      yValueMapper: (SensorData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
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
                    color: Colors.blue[400]!,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                width: 300,
                height: 250,
                child: SfCartesianChart(
                  title: const ChartTitle(
                      text: 'Humidity (40%)',
                      textStyle: TextStyle(color: Colors.white)),
                  primaryXAxis: CategoryAxis(),
                  tooltipBehavior: _tooltipBehavior,
                  series: <LineSeries<SensorData, String>>[
                    LineSeries<SensorData, String>(
                      color: Colors.blue[100],
                      dataSource: _humidityData,
                      xValueMapper: (SensorData data, _) => data.time,
                      yValueMapper: (SensorData data, _) => data.value,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _irrigationAdvice,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorData {
  SensorData(this.time, this.value);

  final String time;
  final double value;
}
