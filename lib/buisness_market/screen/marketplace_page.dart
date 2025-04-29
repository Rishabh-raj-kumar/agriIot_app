// lib/screens/marketplace_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/service_model.dart';
import '../widgets/service_card.dart';
import '../services/add_service.dart'; // Import the new screen

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({Key? key}) : super(key: key);

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  // Filter and Sort State Variables (keep these)
  double? _selectedRatingFilter;
  String _sortByPrice = 'none'; // 'none', 'asc', 'desc'

  // Function to apply filters and sorting AFTER data is fetched
  List<Service> _applyFiltersAndSort(List<Service> services) {
    List<Service> filtered = List.from(services);

    // Apply Rating Filter
    if (_selectedRatingFilter != null) {
      filtered = filtered
          .where((service) => service.rating >= _selectedRatingFilter!)
          .toList();
    }

    // Apply Price Sort
    if (_sortByPrice == 'asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortByPrice == 'desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Bazaar'),
        // backgroundColor: Colors.green, // Theme
        elevation: 2.0,
        // No actions needed here now, FAB is used for adding
      ),
      body: Column(
        children: [
          // Filter Section (keep this widget)
          _buildFilterChips(),
          const Divider(height: 1),

          // Service List - Use StreamBuilder now
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .orderBy('timestamp',
                      descending: true) // Optional: Order by time added
                  .snapshots(),
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle error state
                if (snapshot.hasError) {
                  print("Firestore Error: ${snapshot.error}"); // Log error
                  return Center(
                      child: Text('Error loading services: ${snapshot.error}'));
                }

                // Handle no data state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                          'Oops No services available on Your Region.. Add one!'));
                }

                // Map Firestore documents to Service objects
                List<Service> allServices = snapshot.data!.docs
                    .map((doc) => Service.fromFirestore(doc))
                    .toList();

                // Apply filters and sorting to the fetched data
                List<Service> displayedServices =
                    _applyFiltersAndSort(allServices);

                // Display the list or "no results" message after filtering
                if (displayedServices.isEmpty) {
                  return Center(
                    child: Text(
                      'No services match your filters.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 80.0), // Add padding for FAB
                  itemCount: displayedServices.length,
                  itemBuilder: (context, index) {
                    return ServiceCard(service: displayedServices[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button to Add Service
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          );
        },
        tooltip: 'Add Service',
        // backgroundColor: Colors.green[800], // Theme
        // foregroundColor: Colors.white, // Theme
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget to build the filter chips row (Keep this implementation)
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Rating Filter Dropdown (Keep this)
          DropdownButton<double?>(
            value: _selectedRatingFilter,
            hint: const Text('Min Rating'),
            /* ... items ... */
            onChanged: (value) {
              // Use setState to rebuild the StreamBuilder with new filters
              setState(() {
                _selectedRatingFilter = value;
              });
            },
            items: [],
          ),

          // Price Sort PopupMenuButton (Keep this)
          PopupMenuButton<String>(
            initialValue: _sortByPrice,
            onSelected: (String value) {
              // Use setState to rebuild the StreamBuilder with new sort order
              setState(() {
                _sortByPrice = value;
              });
            },
            /* ... itemBuilder ... */
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'lowToHigh',
                child: Text('Low to High'),
              ),
              const PopupMenuItem<String>(
                value: 'highToLow',
                child: Text('High to Low'),
              ),
            ],
            child: Row(
              children: [
                Text(_sortByPrice == 'lowToHigh'
                    ? 'Sort by Price  '
                    : 'Sort by Price   '),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
