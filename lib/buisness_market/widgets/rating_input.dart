import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingInput extends StatefulWidget {
  final Function(double rating, String? comment) onSubmit;
  final double initialRating;

  const RatingInput(
      {super.key, required this.onSubmit, this.initialRating = 0.0});

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  late double _currentRating;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for BottomSheet
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rate this Service",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 15),
          Center(
            child: RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _currentRating = rating;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text("Add a comment (optional)",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Share your experience...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _currentRating > 0
                  ? () {
                      widget.onSubmit(
                          _currentRating, _commentController.text.trim());
                      Navigator.pop(context); // Close the input area/dialog
                    }
                  : null, // Disable button if no rating selected
              child: const Text('Submit Rating'),
            ),
          ),
          const SizedBox(height: 10), // Add padding for keyboard overlap
        ],
      ),
    );
  }
}
