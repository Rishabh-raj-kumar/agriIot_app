import 'package:flutter/material.dart';

class FilterOptions {
  double? maxDistanceKm;
  double? minPrice;
  double? maxPrice;
  double? minRating;
  String? category;

  FilterOptions(
      {this.maxDistanceKm,
      this.minPrice,
      this.maxPrice,
      this.minRating,
      this.category});
}

class FilterDialog extends StatefulWidget {
  final FilterOptions initialFilters;
  final List<String> availableCategories; // Pass available categories

  const FilterDialog({
    super.key,
    required this.initialFilters,
    required this.availableCategories,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions _currentFilters;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _distanceController = TextEditingController();

  final List<double> _ratingOptions = [0, 1, 2, 3, 4, 5]; // 0 for no filter
  final List<double> _distanceOptions = [
    0,
    5,
    10,
    25,
    50,
    100
  ]; // 0 for no filter (in km)

  @override
  void initState() {
    super.initState();
    _currentFilters = FilterOptions(
      maxDistanceKm: widget.initialFilters.maxDistanceKm,
      minPrice: widget.initialFilters.minPrice,
      maxPrice: widget.initialFilters.maxPrice,
      minRating: widget.initialFilters.minRating,
      category: widget.initialFilters.category,
    );

    // Initialize controllers
    if (_currentFilters.minPrice != null) {
      _minPriceController.text = _currentFilters.minPrice!.toStringAsFixed(0);
    }
    if (_currentFilters.maxPrice != null) {
      _maxPriceController.text = _currentFilters.maxPrice!.toStringAsFixed(0);
    }
    if (_currentFilters.maxDistanceKm != null &&
        _currentFilters.maxDistanceKm! > 0) {
      _distanceController.text =
          _currentFilters.maxDistanceKm!.toStringAsFixed(0);
    } else {
      _currentFilters.maxDistanceKm = null; // Ensure 0 means null internally
    }
    // Ensure 0 rating means null internally
    if (_currentFilters.minRating == 0) _currentFilters.minRating = null;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Filter Services"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Distance Filter ---
            const Text("Distance Range (km)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<double>(
              value: _currentFilters.maxDistanceKm ??
                  0, // Use 0 to represent "Any" in UI
              isExpanded: true,
              items: _distanceOptions.map((distance) {
                return DropdownMenuItem<double>(
                  value: distance,
                  child: Text(distance == 0
                      ? "Any Distance"
                      : "Within ${distance.toInt()} km"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _currentFilters.maxDistanceKm = (value == 0) ? null : value;
                });
              },
            ),
            /* // Alternative: Text input for distance
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Max Distance (km)",
                hintText: "e.g., 10",
              ),
              onChanged: (value) {
                 _currentFilters.maxDistanceKm = double.tryParse(value);
              },
            ),
            */
            const SizedBox(height: 16),

            // --- Price Range Filter ---
            const Text("Price Range (₹/hour)",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Min Price"),
                    onChanged: (value) {
                      _currentFilters.minPrice = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Text("to"),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Max Price"),
                    onChanged: (value) {
                      _currentFilters.maxPrice = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Category Filter ---
            const Text("Category",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _currentFilters.category,
              isExpanded: true,
              hint: const Text("Select Category"),
              items: [
                const DropdownMenuItem<String>(
                  value: null, // Represents 'All Categories'
                  child: Text("All Categories"),
                ),
                ...widget.availableCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList()
              ],
              onChanged: (value) {
                setState(() {
                  _currentFilters.category = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // --- Rating Filter ---
            const Text("Minimum Rating",
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<double>(
              value: _currentFilters.minRating ??
                  0, // Use 0 to represent "Any" in UI
              isExpanded: true,
              items: _ratingOptions.map((rating) {
                return DropdownMenuItem<double>(
                  value: rating,
                  child: Text(
                      rating == 0 ? "Any Rating" : "${rating.toInt()}+ Stars"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _currentFilters.minRating = (value == 0) ? null : value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Clear filters
            setState(() {
              _currentFilters = FilterOptions(); // Reset to default
              _minPriceController.clear();
              _maxPriceController.clear();
              _distanceController.clear();
            });
            Navigator.of(context)
                .pop(_currentFilters); // Return cleared filters
          },
          child: const Text("Clear All"),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate price range if needed
            if (_currentFilters.minPrice != null &&
                _currentFilters.maxPrice != null &&
                _currentFilters.minPrice! > _currentFilters.maxPrice!) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Min price cannot be greater than max price")),
              );
              return; // Don't close dialog
            }
            Navigator.of(context).pop(_currentFilters); // Apply filters
          },
          child: const Text("Apply"),
        ),
      ],
    );
  }
}
