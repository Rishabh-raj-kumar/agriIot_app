import 'package:agriculture/main.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agriculture/Auth/AuthWrapper.dart'; // Your existing AuthWrapper import

class PermissionHandlerWrapper extends StatefulWidget {
  const PermissionHandlerWrapper({super.key});

  @override
  State<PermissionHandlerWrapper> createState() =>
      _PermissionHandlerWrapperState();
}

class _PermissionHandlerWrapperState extends State<PermissionHandlerWrapper> {
  bool _permissionCheckComplete = false;
  PermissionStatus? _locationStatus; // To optionally store the status

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  Future<void> _checkAndRequestLocationPermission() async {
    // Request "location when in use". Change if you need "always" access.
    PermissionStatus status = await Permission.locationWhenInUse.status;
    print('Initial location permission status: $status');

    if (!status.isGranted) {
      // If not granted, request it
      status = await Permission.locationWhenInUse.request();
      print('Location permission status after request: $status');
    }

    // You can store the status if needed elsewhere, but for now,
    // we just need to know the check/request process is done.
    _locationStatus = status;

    // Regardless of granted or denied, mark the check as complete
    // so the app can proceed to the AuthWrapper.
    if (mounted) {
      // Ensure the widget is still in the tree
      setState(() {
        _permissionCheckComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionCheckComplete) {
      // While checking/requesting permission, show a loading indicator.
      // This screen is briefly visible while the permission dialog might be showing.
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // Permission check is done (granted or denied), proceed to AuthWrapper
      return const LanguageSelectionPage();
    }
  }
}
