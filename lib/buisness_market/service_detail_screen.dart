// lib/screens/service_detail_screen.dart

import 'package:flutter/material.dart';
import './service.dart'; // Import Service and Comment models
import 'package:intl/intl.dart'; // Add intl package for date formatting (add to pubspec.yaml)

class ServiceDetailScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailScreen({Key? key, required this.service})
      : super(key: key);

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  // In a real app, comments would likely be fetched from a database
  // We are using the list within the Service object for simplicity here.
  void Print() {
    print("url : ${widget.service.imageUrl}");
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) {
      return; // Don't add empty comments
    }

    // Simulate adding a comment from a logged-in user
    // In a real app, you'd use the actual user's ID and name
    final newComment = Comment(
      userId: 'user123', // Replace with actual user ID
      userName: 'Farmer John', // Replace with actual user name
      text: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    setState(() {
      widget.service.comments.add(newComment);
      // In a real app, you would also save this comment to your backend/database
    });

    _commentController.clear(); // Clear the input field
    // Optionally hide the keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                widget.service.imageUrl,
                width: double.infinity, // Take full width
                height: 200, // Fixed height
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    // Placeholder on error
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[600], size: 50),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            // Service Name
            Text(
              widget.service.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),

            // Service Description
            Text(
              widget.service.description,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16.0),

            // Price, Rating, Location, Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\₹${widget.service.pricePerHour.toStringAsFixed(2)} / hour',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20.0),
                    const SizedBox(width: 4.0),
                    Text(
                      widget.service.rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'Location: ${widget.service.location}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Category: ${widget.service.category}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 24.0),

            // Comments Section
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 20, thickness: 1),

            // Add Comment Input
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 15.0),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null, // Allow multiple lines
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _addComment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // List of Comments
            widget.service.comments.isEmpty
                ? const Center(child: Text('No comments yet.'))
                : ListView.builder(
                    shrinkWrap:
                        true, // Important for ListView inside SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: widget.service.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.service.comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_circle,
                                    color: Colors.grey[600], size: 20),
                                const SizedBox(width: 4.0),
                                Text(
                                  comment.userName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm')
                                      .format(comment.timestamp), // Format date
                                  style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0), // Indent comment text
                              child: Text(comment.text),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
