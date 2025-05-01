import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'dart:io'; // For File
import 'dart:async'; // For TimeoutException
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:http_parser/http_parser.dart'; // Required for MediaType.
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path; // Use 'as path' to avoid conflicts

// Assuming ChatMessageWidget is in this path and correctly displays text/images
import 'package:agriculture/chatbot/chat_messsage.dart';

// --- Data structure for messages ---
class Message {
  final String text;
  final bool isUser;
  final File? imageFile; // Image associated with the message

  Message({required this.text, required this.isUser, this.imageFile});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); // Image Picker instance
  final List<Message> _messages = [];
  bool _isBotTyping = false;
  bool _isSendingMessage = false; // Tracks if a message is currently being sent
  bool _canSendMessage = false;
  // --- IMPORTANT: Your Render Backend URL ---
  // Ensure this is the correct HTTPS URL provided by Render
  final String _apiUrl = 'https://apnikheti.onrender.com/api/chatbot';

  // --- Quick Replies ---
  final List<String> _quickReplies = [
    "What crops grow well here?",
    "Identify plant diseases",
    "Common pests in Bihar?",
    "Suggest organic fertilizer",
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "Hello! 👋 Ask me about agriculture in Bihar or upload a plant image for analysis.");
    _controller.addListener(_updateSendButtonState);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSendButtonState);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // *** ADDED: Method to update send button state ***
  void _updateSendButtonState() {
    if (!mounted) return;
    setState(() {
      _canSendMessage = _controller.text.trim().isNotEmpty;
    });
  }

  // --- Utility Functions ---
  void _scrollToBottom() {
    // Scrolls to the latest message after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackbar(String message) {
    // Shows a red snackbar for errors
    if (!mounted) return; // Check if the widget is still in the tree
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- Add Messages to UI ---
  void _addBotMessage(String text) {
    // Adds a message from the bot to the UI
    if (!mounted) return;
    setState(() {
      _messages.add(Message(text: text, isUser: false, imageFile: null));
      _isBotTyping = false; // Bot finished "typing"
      _isSendingMessage = false; // Allows user to send again
      _updateSendButtonState();
    });
    _scrollToBottom();
  }

  void _addUserMessage({required String text, File? imageFile}) {
    // Adds a user message (text or image) to the UI and triggers API call
    if (_isSendingMessage) return; // Prevent sending while already sending

    // Basic check for empty text when no image is provided
    if (text.trim().isEmpty && imageFile == null) return;

    if (!mounted) return;
    setState(() {
      _messages.add(Message(text: text, isUser: true, imageFile: imageFile));
      _isSendingMessage = true; // Lock UI elements
      _isBotTyping = true; // Show typing indicator
    });
    _controller.clear(); // Clear input field
    _scrollToBottom();

    // Call the API function
    _callChatbotApi(userInput: text, image: imageFile);
  }

  // --- Image Picking ---
  Future<void> _pickImage(ImageSource source) async {
    if (_isSendingMessage) return; // Don't allow picking if already sending

    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: source, imageQuality: 85 // Quality setting (0-100)
          );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        // Add the image message to the UI and send it
        // You could optionally allow adding text here too before sending
        _addUserMessage(
            text: "", imageFile: imageFile); // Send image immediately
      }
    } catch (e) {
      print("Image picking error: $e");
      _showErrorSnackbar("Could not pick image: $e");
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    // Shows modal sheet to choose Camera or Gallery
    if (_isSendingMessage) return; // Don't show if already sending

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the sheet
                    _pickImage(ImageSource.gallery);
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the sheet
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Unified API Call Function (FIXED) ---
  Future<void> _callChatbotApi({String? userInput, File? image}) async {
    if ((userInput == null || userInput.trim().isEmpty) && image == null) {
      print("Error: No text or image provided for API call.");
      // No need to add bot message here, handled by resetting state in finally
      if (mounted) {
        // Reset state immediately
        setState(() {
          _isBotTyping = false;
          _isSendingMessage = false;
          _updateSendButtonState();
        });
      }
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

    if (userInput != null) {
      request.fields['user_input'] = userInput;
      print("API Call: Adding text field: '$userInput'");
    }

    if (image != null) {
      try {
        // *** ADDED: Determine MIME type ***
        String? mimeType = lookupMimeType(image.path);
        MediaType? mediaType;
        if (mimeType != null) {
          mediaType = MediaType.parse(mimeType);
          print("API Call: Determined MIME type: $mimeType");
        } else {
          print(
              "API Call: Could not determine MIME type for ${path.basename(image.path)}. Sending without explicit content type.");
          // Optionally default to a common type or let the backend handle it
          // mediaType = MediaType('image', 'jpeg'); // Example fallback
        }

        request.files.add(await http.MultipartFile.fromPath(
          'image', // Field name MUST match Flask backend
          image.path,
          filename: path.basename(image.path),
          contentType:
              mediaType, // *** CHANGED: Set determined content type ***
        ));
        print(
            "API Call: Adding image file: ${path.basename(image.path)} with content type: ${mediaType?.toString() ?? 'Unknown'}");
      } catch (e) {
        print("Error attaching image file to request: $e");
        _addBotMessage("Error preparing image for upload. Please try again.");
        // Reset state immediately since the request won't be sent
        if (mounted) {
          setState(() {
            _isBotTyping = false;
            _isSendingMessage = false;
            _updateSendButtonState();
          });
        }
        return;
      }
    }

    // Make the API call
    try {
      print("API Call: Sending request to $_apiUrl...");

      // Send the request with a timeout
      final streamedResponse = await request.send().timeout(const Duration(
          seconds: 90)); // Increased timeout for potential slow AI calls
      print("API Call: Received response stream.");

      final response = await http.Response.fromStream(streamedResponse);
      print("API Call: Received response status: ${response.statusCode}");
      print(
          "API Call: Response body: ${response.body.substring(0, (response.body.length > 500 ? 500 : response.body.length))}..."); // Log beginning of body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addBotMessage(data['response'] ?? "Received an empty response.");
      } else {
        // Handle non-200 status codes (errors)
        _handleApiError(response);
      }
    } on TimeoutException catch (e) {
      print('API Call Error: Request timed out: $e');
      _addBotMessage("The request took too long to process. Please try again.");
      _showErrorSnackbar("Request timed out. The server might be busy.");
    } catch (e) {
      // Handle network errors, DNS errors, etc.
      print('API Call Error: Network or other error: $e');
      _addBotMessage(
          "Connection Error: Could not reach the server. Please check your connection and try again.");
      _showErrorSnackbar("Connection error. Please check network.");
    } finally {
      // Ensure the UI state is always reset, regardless of success or failure
      if (mounted) {
        setState(() {
          _isBotTyping = false;
          _isSendingMessage = false;
          _updateSendButtonState();
        });
      }
    }
  }

  // --- Helper to handle API errors (non-200 status) ---
  void _handleApiError(http.Response response) {
    String errorMessage =
        "An error occurred (Code: ${response.statusCode}). Please try again.";
    try {
      // Try to decode a more specific error message from the JSON response
      final data = jsonDecode(response.body);
      errorMessage = data['response'] ?? data['error'] ?? errorMessage;
      // Add specific hints for common Render issues
      if (response.statusCode == 503 || response.statusCode == 502) {
        errorMessage +=
            "\n(This might indicate the backend service is restarting or having issues. Please wait a moment and try again. Check Render status if persistent.)";
      }
    } catch (_) {
      // If response body is not JSON or parsing fails, use the raw body (truncated) or default message
      errorMessage = response.body.isNotEmpty
          ? "Server Error (${response.statusCode}): ${response.body.substring(0, (response.body.length > 150 ? 150 : response.body.length))}"
          : errorMessage; // Use default if body is empty
    }
    _addBotMessage(errorMessage); // Add error details to chat history
    _showErrorSnackbar(
        "API Error: ${response.statusCode}"); // Show brief snackbar
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isSendButtonEnabled = _canSendMessage && !_isSendingMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Apni Kheti Assistant"), // Updated Title
        elevation: 1.0,
        backgroundColor: Colors.green[800], // Darker Green
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          // Chat messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Ensure ChatMessageWidget can handle 'imageFile'
                return ChatMessageWidget(
                  text: message.text,
                  isUserMessage: message.isUser,
                  imageFile: message.imageFile,
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isBotTyping)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[200], // Match bot bubble
                    child: Icon(Icons.agriculture, // Themed Icon
                        size: 18,
                        color: Colors.green[700]),
                  ),
                  const SizedBox(width: 8),
                  SpinKitThreeBounce(
                    color: Colors.green[600], // Themed color
                    size: 20.0,
                  ),
                ],
              ),
            ),

          // Quick Replies (Only show when idle)
          if (_quickReplies.isNotEmpty && !_isBotTyping && !_isSendingMessage)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Align left
                  children: _quickReplies.map((reply) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ActionChip(
                        label: Text(reply),
                        onPressed: () => _addUserMessage(
                            text: reply), // Use unified function
                        backgroundColor: Colors.lightGreen[50], // Lighter green
                        labelStyle: TextStyle(
                            color: Colors.green[900],
                            fontSize: 13), // Darker text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.green[200]!),
                        ),
                        tooltip: "Send: $reply",
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // Tighter tap area
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0), // Adjust padding
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Input area Divider
          const Divider(height: 1.0),

          // Input area Container
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                // Image Picker Button
                IconButton(
                  icon: Icon(Icons.camera_alt_outlined, // Changed icon
                      color: _isSendingMessage
                          ? Colors.grey // Disabled color
                          : Colors.green[700]), // Enabled color
                  onPressed: _isSendingMessage
                      ? null // Disable when sending
                      : () => _showImageSourceActionSheet(context),
                  tooltip: 'Attach Image',
                ),
                const SizedBox(width: 4.0),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: isSendButtonEnabled
                        ? (value) => _addUserMessage(text: value)
                        : null, // Use unified function
                    decoration: InputDecoration(
                      hintText: "Ask or describe image...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    enabled: !_isSendingMessage, // Disable field when sending
                    style: TextStyle(
                        color: _isSendingMessage ? Colors.grey : Colors.black),
                    onChanged: (_) => _updateSendButtonState(),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Send Button (Shows loader when sending)
                Material(
                  color: isSendButtonEnabled
                      ? Colors.green[700] // Enabled color
                      : Colors.grey, // Enabled color
                  borderRadius: BorderRadius.circular(25.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25.0),
                    onTap: isSendButtonEnabled
                        ? () => _addUserMessage(text: _controller.text)
                        : null, // Use unified function
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _isSendingMessage
                          ? const SizedBox(
                              // Show loader
                              width: 24.0,
                              height: 24.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(
                              // Show send icon
                              Icons.send,
                              color: Colors.white,
                              size: 24.0,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
