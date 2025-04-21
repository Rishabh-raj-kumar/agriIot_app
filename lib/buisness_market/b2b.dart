// lib/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import './service.dart'; // Import Service model
import './service_card.dart'; // Import ServiceCard widget
import 'service_detail_screen.dart'; // Import ServiceDetailScreen
import './add_service.dart'; // Import AddServiceScreen

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  // --- Sample Data ---
  // This list will now be the source of truth and will be modified when a new service is added
  final List<Service> _allServices = [
    Service(
        id: 's1',
        name: 'Tractor Rental',
        description: 'Powerful tractor for plowing and tilling.',
        pricePerHour: 50.0,
        rating: 4.5,
        category: 'Machinery',
        location: 'Rural Area A',
        imageUrl:
            "https://www.deere.co.in/assets/images/region-1/products/tractors/john-deere-e-series-cab.jpg",
        comments: [
          Comment(
              userId: 'u1',
              userName: 'Alice',
              text: 'Great service!',
              timestamp: DateTime.now().subtract(Duration(days: 1))),
          Comment(
              userId: 'u2',
              userName: 'Bob',
              text: 'Tractor was in good condition.',
              timestamp: DateTime.now().subtract(Duration(hours: 5))),
        ]),
    Service(
        id: 's2',
        name: 'Pesticide Spraying',
        description: 'Professional pest control service.',
        pricePerHour: 30.0,
        rating: 4.8,
        category: 'Pest Control',
        location: 'Rural Area B',
        imageUrl: 'https://source.unsplash.com/150x150/?pest+control',
        comments: [
          Comment(
              userId: 'u3',
              userName: 'Charlie',
              text: 'Very effective!',
              timestamp: DateTime.now().subtract(Duration(days: 2))),
        ]),
    Service(
        id: 's3',
        name: 'Harvesting Equipment',
        description: 'Combine harvester for efficient harvesting.',
        pricePerHour: 100.0,
        rating: 4.2,
        category: 'Machinery',
        location: 'Rural Area A',
        imageUrl: 'https://source.unsplash.com/150x150/?harvester',
        comments: [] // No comments yet
        ),
    Service(
        id: 's4',
        name: 'Soil Testing',
        description: 'Comprehensive soil analysis.',
        pricePerHour: 20.0,
        rating: 4.9,
        category: 'Consulting',
        location: 'Rural Area C',
        imageUrl: 'https://source.unsplash.com/150x150/?soil+test',
        comments: []),
    Service(
        id: 's5',
        name: 'Irrigation System Repair',
        description: 'Repair and maintenance for irrigation systems.',
        pricePerHour: 40.0,
        rating: 4.0,
        category: 'Maintenance',
        location: 'Rural Area B',
        imageUrl: 'https://source.unsplash.com/150x150/?irrigation',
        comments: []),
  ];

  List<Service> _filteredServices = [];

  // --- Filter State ---
  String _selectedLocation = 'All Locations'; // Default filter
  double _priceRangeStart = 0.0;
  double _priceRangeEnd = 150.0; // Max price in sample data + some buffer
  double _minRating = 0.0;
  String _selectedCategory = 'All Categories';

  // Available filter options (derived from data or predefined)
  // Note: These should ideally recalculate if new services add new locations/categories
  List<String> get _availableLocations {
    Set<String> locations = _allServices.map((s) => s.location).toSet();
    return ['All Locations', ...locations.toList()];
  }

  List<String> get _availableCategories {
    Set<String> categories = _allServices.map((s) => s.category).toSet();
    return ['All Categories', ...categories.toList()];
  }

  @override
  void initState() {
    super.initState();
    _filteredServices = List.from(_allServices); // Create a mutable copy
    _applyFilters(); // Apply initial filters (which are default)
  }

  // --- Filtering Logic ---
  void _applyFilters() {
    List<Service> tempList = _allServices;

    // Filter by Location
    if (_selectedLocation != 'All Locations') {
      tempList = tempList
          .where((service) => service.location == _selectedLocation)
          .toList();
    }

    // Filter by Price Range
    tempList = tempList
        .where((service) =>
            service.pricePerHour >= _priceRangeStart &&
            service.pricePerHour <= _priceRangeEnd)
        .toList();

    // Filter by Rating
    tempList =
        tempList.where((service) => service.rating >= _minRating).toList();

    // Filter by Category
    if (_selectedCategory != 'All Categories') {
      tempList = tempList
          .where((service) => service.category == _selectedCategory)
          .toList();
    }

    setState(() {
      _filteredServices = tempList;
    });
  }

  // --- UI for Filters (Example using ExpansionTile) ---
  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: Colors.grey)),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              offset: Offset(0, 2),
              blurRadius: 10,
            ),
          ]),
      child: ExpansionTile(
        title: const Text('Filters'),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Filter
                const Text('Location:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedLocation,
                  items: _availableLocations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                      _applyFilters();
                    }
                  },
                ),
                const SizedBox(height: 16.0),

                // Price Range Filter
                const Text('Price Range per Hour:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                RangeSlider(
                  values: RangeValues(_priceRangeStart, _priceRangeEnd),
                  min: 0.0,
                  max: 150.0, // Adjust max based on expected data
                  divisions: 30, // Example divisions
                  labels: RangeLabels(
                    '\$₹{_priceRangeStart.round()}',
                    '\$₹{_priceRangeEnd.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRangeStart = values.start;
                      _priceRangeEnd = values.end;
                    });
                  },
                  onChangeEnd: (RangeValues values) {
                    _applyFilters(); // Apply filter when user finishes dragging
                  },
                ),
                Text(
                    'Range: \₹${_priceRangeStart.toStringAsFixed(0)} - \₹${_priceRangeEnd.toStringAsFixed(0)}'),

                const SizedBox(height: 16.0),

                // Rating Filter
                const Text('Minimum Rating:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _minRating,
                  min: 0.0,
                  max: 5.0,
                  divisions: 10, // 0.0, 0.5, 1.0, ..., 5.0
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      _minRating = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    _applyFilters(); // Apply filter when user finishes dragging
                  },
                ),
                Text('Minimum: ${_minRating.toStringAsFixed(1)} stars'),
                const SizedBox(height: 16.0),

                // Category Filter
                const Text('Category:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: _availableCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                      _applyFilters();
                    }
                  },
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Navigate to Add Service Screen ---
  void _navigateToAddService() async {
    final newService = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddServiceScreen()),
    );

    // If a new service was returned from the AddServiceScreen
    if (newService != null && newService is Service) {
      setState(() {
        _allServices.add(newService); // Add the new service to our main list
        // Re-apply filters to include the new service if it matches
        _applyFilters();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newService.name} added successfully!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Marketplace'),
        backgroundColor: Colors.blue[500], // Example theme color
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Service List
          Expanded(
            child: _filteredServices.isEmpty
                ? Center(child: Text('No services found matching criteria.'))
                : ListView.builder(
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return ServiceCard(
                        service: service,
                        onTap: () {
                          // Navigate to Service Detail Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ServiceDetailScreen(service: service),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // Floating Action Button to Add New Service
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddService,
        tooltip: 'Add New Service',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
