// lib/widgets/service_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart'; // Keep for Distance calculation display (optional here)
import 'package:location/location.dart'; // Import location package
import '../model/service_model.dart';
import '../screen/map_display_screen.dart';

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  // Function to launch WhatsApp (Refined)
  Future<void> _launchWhatsApp(String phoneNumber, BuildContext context) async {
    String formattedNumber = phoneNumber.replaceAll(RegExp(r'[-\s]'), '');

    // Ensure international format (assuming +91 for India if missing)
    if (!formattedNumber.startsWith('+')) {
      if (formattedNumber.length == 10) {
        formattedNumber = '+91$formattedNumber';
      } else if (formattedNumber.length == 11 &&
          formattedNumber.startsWith('0')) {
        // Handle numbers like 0987... -> +91987...
        formattedNumber = '+91${formattedNumber.substring(1)}';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid phone number format: $phoneNumber')),
        );
        return;
      }
    }

    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedNumber');
    // Optional: Pre-fill message
    // final Uri whatsappUriWithMessage = Uri.parse('https://wa.me/$formattedNumber?text=Hello%20regarding%20${service.title}');

    try {
      // No need for canLaunchUrl with https, launchUrl handles it
      bool launched = await launchUrl(whatsappUri,
          mode: LaunchMode.externalApplication // Try opening externally first
          );

      if (!launched) {
        // Fallback or specific error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not launch WhatsApp. Is it installed?')),
        );
      }
    } catch (e) {
      print("WhatsApp Launch Error: $e"); // Log error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching WhatsApp: $e')),
      );
    }
  }

  // Function to get user location and navigate to map
  Future<void> _viewMap(BuildContext context) async {
    Location location = Location(); // Create instance
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData? locationData; // Make nullable

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        // Optionally navigate without user location
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapDisplayScreen(
              serviceLocation: service.location,
              serviceProviderName: service.sellerName,
              // userLocation: null // Explicitly null
            ),
          ),
        );
        return; // Stop if service not enabled
      }
    }

    // Check for location permissions
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        // Optionally navigate without user location
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapDisplayScreen(
              serviceLocation: service.location,
              serviceProviderName: service.sellerName,
              // userLocation: null // Explicitly null
            ),
          ),
        );
        return; // Stop if permissions not granted
      }
    }

    // Get current location
    try {
      // Using requestLocation for a one-time fetch
      locationData = await location.getLocation();
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location: $e')),
      );
      // Navigate without user location on error
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapDisplayScreen(
            serviceLocation: service.location,
            serviceProviderName: service.sellerName,
            // userLocation: null // Explicitly null
          ),
        ),
      );
      return;
    }

    // Navigate to map with both locations
    if (locationData.latitude != null && locationData.longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapDisplayScreen(
            serviceLocation: service.location,
            serviceProviderName: service.sellerName,
            userLocation:
                LatLng(locationData!.latitude!, locationData.longitude!),
          ),
        ),
      );
    } else {
      // Handle case where location data is unexpectedly null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to retrieve valid location coordinates.')),
      );
      // Navigate without user location as fallback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapDisplayScreen(
            serviceLocation: service.location,
            serviceProviderName: service.sellerName,
            // userLocation: null // Explicitly null
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- CARD UI --- (Keep the previous Card UI structure)
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image (same as before)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: service.imageUrl.isNotEmpty
                    ? service.imageUrl
                    : 'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=No+Image', // Placeholder if URL is empty
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                fit: BoxFit.cover,
                // loadingBuilder: ({context, child, loadingProgress}),
                // errorBuilder: (context, error, stackTrace),
              ),
            ),

            // Details Section (same as before)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(service.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(4.0)),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 20.0, color: Colors.red),
                            Text('Shop : ${service.sellerName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Colors.grey[700],
                                        decoration: TextDecoration.underline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(service.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹ ${service.price} / ${service.priceUnit}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      // Add other widgets here if needed
                    ],
                  ),

                  // Price and Rating Row (same as before)
                  Row(/* ... */),
                ],
              ),
            ),

            // Buttons Section (Updated onPressed for map)
            const Divider(height: 1, thickness: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.map_outlined, color: Colors.blue[700]),
                    label: Text('View Map',
                        style: TextStyle(color: Colors.blue[700])),
                    onPressed: () {
                      _viewMap(context); // Call the new function
                    },
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.chat_bubble_outline,
                        color: Colors.teal[700]),
                    label: Text('WhatsApp',
                        style: TextStyle(color: Colors.teal[700])),
                    onPressed: () {
                      _launchWhatsApp(service.contactNumber, context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
