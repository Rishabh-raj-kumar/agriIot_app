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

  @override
  void initState() {
    super.initState();
    _soilMoistureData = getSoilMoistureData();
    _humidityData = getHumidityData();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  List<SensorData> getSoilMoistureData() {
    final List<SensorData> chartData = [
      SensorData('00:00', 40),
      SensorData('03:00', 45),
      SensorData('06:00', 55),
      SensorData('09:00', 60),
      SensorData('12:00', 70),
      SensorData('15:00', 65),
      SensorData('18:00', 50),
      SensorData('21:00', 48),
      SensorData('24:00', 42),
    ];
    return chartData;
  }

  List<SensorData> getHumidityData() {
    final List<SensorData> chartData = [
      SensorData('00:00', 60),
      SensorData('03:00', 65),
      SensorData('06:00', 70),
      SensorData('09:00', 75),
      SensorData('12:00', 80),
      SensorData('15:00', 78),
      SensorData('18:00', 72),
      SensorData('21:00', 68),
      SensorData('24:00', 62),
    ];
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SfCartesianChart(
            title: ChartTitle(text: 'Soil Moisture (%)'),
            primaryXAxis: CategoryAxis(),
            tooltipBehavior: _tooltipBehavior,
            series: <LineSeries<SensorData, String>>[
              LineSeries<SensorData, String>(
                dataSource: _soilMoistureData,
                xValueMapper: (SensorData data, _) => data.time,
                yValueMapper: (SensorData data, _) => data.value,
              ),
            ],
          ),
          SfCartesianChart(
            title: ChartTitle(text: 'Humidity (%)'),
            primaryXAxis: CategoryAxis(),
            tooltipBehavior: _tooltipBehavior,
            series: <LineSeries<SensorData, String>>[
              LineSeries<SensorData, String>(
                dataSource: _humidityData,
                xValueMapper: (SensorData data, _) => data.time,
                yValueMapper: (SensorData data, _) => data.value,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SensorData {
  SensorData(this.time, this.value);

  final String time;
  final double value;
}
