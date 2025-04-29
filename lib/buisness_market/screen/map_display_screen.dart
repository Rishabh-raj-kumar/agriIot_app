// lib/screens/map_display_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapDisplayScreen extends StatelessWidget {
  final LatLng serviceLocation;
  final String serviceProviderName;
  final LatLng? userLocation; // Make user location nullable

  const MapDisplayScreen({
    Key? key,
    required this.serviceLocation,
    required this.serviceProviderName,
    this.userLocation, // Receive user location
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = MapController(); // Controller for map interactions
    String distanceText = '';
    List<LatLng> polylinePoints = [];
    List<Marker> markers = [];

    // Add service provider marker
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: serviceLocation,
        child: Tooltip(
          message: serviceProviderName,
          child: Icon(
            Icons.storefront, // Shop/Service icon
            color: Colors.redAccent,
            size: 40.0,
          ),
        ),
      ),
    );

    // Add user marker and calculate distance if location is available
    if (userLocation != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: userLocation!,
          child: Tooltip(
            message: "Your Location",
            child: Icon(
              Icons.person_pin_circle, // User location icon
              color: Colors.blueAccent,
              size: 40.0,
            ),
          ),
        ),
      );

      // Calculate distance
      const Distance distanceCalc = Distance();
      final double distanceInMeters =
          distanceCalc(userLocation!, serviceLocation);
      distanceText =
          (distanceInMeters / 1000).toStringAsFixed(2) + ' km'; // Convert to km

      // Add points for polyline
      polylinePoints = [userLocation!, serviceLocation];
    }

    // Determine map bounds or center
    LatLng initialCenter = serviceLocation;
    double initialZoom = 14.0;
    if (userLocation != null) {
      // Calculate bounds to fit both markers
      var bounds = LatLngBounds.fromPoints([userLocation!, serviceLocation]);
      // Use fitBounds in options later if mapController is ready
      // For now, center between the two points
      initialCenter = LatLng(
        (userLocation!.latitude + serviceLocation.latitude) / 2,
        (userLocation!.longitude + serviceLocation.longitude) / 2,
      );
      // Note: Calculating optimal zoom is more complex, setting a moderate default
      initialZoom = 12.0; // Zoom out slightly if showing two points far apart
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceProviderName),
            if (distanceText.isNotEmpty)
              Text("Distance: $distanceText",
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        // backgroundColor: Colors.green[700], // Handled by theme potentially
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          // Use bounds to fit markers after map is ready (optional enhancement)
          // onMapReady: () {
          //   if (userLocation != null) {
          //     var bounds = LatLngBounds.fromPoints([userLocation!, serviceLocation]);
          //     mapController.fitBounds(bounds, options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));
          //   }
          // },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.your_app_name', // Replace with your app package name
          ),
          // Draw polyline if points exist
          if (polylinePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  strokeWidth: 4.0,
                  color: Colors.blue.withOpacity(0.7),
                ),
              ],
            ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
