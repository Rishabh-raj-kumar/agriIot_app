import 'dart:io' show Platform;
import 'package:agriculture/Home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchedulerPage extends StatefulWidget {
  const SchedulerPage({super.key});

  @override
  _SchedulerPageState createState() => _SchedulerPageState();
}

class _SchedulerPageState extends State<SchedulerPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _taskDescription = 'Water Plants';
  List<Map<String, dynamic>> _scheduledTasks = [];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadScheduledTasks();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadScheduledTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('scheduledTasks');
    if (tasksJson != null) {
      try {
        final decodedTasks = json.decode(tasksJson) as List;
        setState(() {
          _scheduledTasks =
              decodedTasks.map((e) => e as Map<String, dynamic>).toList();
        });
        print('Loaded tasks: $_scheduledTasks');
      } catch (e) {
        print('Error loading tasks: $e');
      }
    } else {
      print('No saved tasks found.');
    }
  }

  Future<void> _saveScheduledTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduledTasks', json.encode(_scheduledTasks));
  }

  Future<void> _scheduleNotification() async {
    if (Platform.isAndroid && Platform.version.startsWith('31')) {
      var status = await Permission.scheduleExactAlarm.status;
      if (status.isDenied) {
        status = await Permission.scheduleExactAlarm.request();
        if (status.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exact alarm permission denied.')),
          );
          return;
        }
      }
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exact alarm permission denied.')),
        );
        return;
      }
    }

    final scheduledDateTime = tz.TZDateTime(
      tz.local,
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    print('Scheduling notification for: $scheduledDateTime');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      _scheduledTasks.length, // Unique ID
      _taskDescription, // Use _taskDescription as the title
      'Reminder', // Use "Reminder" as the body.
      scheduledDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          '0',
          'Scheduler Channel',
          channelDescription: 'Scheduler notifications',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    final newTask = {
      'description': _taskDescription,
      'date': _selectedDate.toIso8601String(),
      'time': _selectedTime.format(context),
    };

    setState(() {
      _scheduledTasks.add(newTask);
    });

    _saveScheduledTasks();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('scheduledTasks')
        .doc(_scheduledTasks.length.toString())
        .set(newTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification scheduled!')),
    );

    await Future.delayed(const Duration(milliseconds: 700));
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    ).then((value) => setState(() {}));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduler')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Task Description'),
              onChanged: (value) {
                _taskDescription = value;
                print('Task Description: $_taskDescription'); // Debugging
              },
            ),
            ListTile(
              title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text('Time: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: const Text('Schedule Notification'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scheduledTasks.length,
                itemBuilder: (context, index) {
                  final task = _scheduledTasks[index];
                  return ListTile(
                    title: Text(task['description']),
                    subtitle: Text(
                        '${task['date'].substring(0, 10)} ${task['time']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
