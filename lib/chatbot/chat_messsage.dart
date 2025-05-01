import 'package:flutter/material.dart';
import 'dart:io'; // For File
import 'package:flutter/rendering.dart'; // Required for PlaceholderAlignment

// --- Updated ChatMessageWidget ---
class ChatMessageWidget extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  final File? imageFile;

  const ChatMessageWidget({
    super.key,
    required this.text,
    required this.isUserMessage,
    this.imageFile,
  });

  // --- Helper Function to Parse Text for Bold Formatting ---
  // This function takes a text segment and returns a list of TextSpans
  // handling the **bold** syntax.
  List<TextSpan> _parseBoldText(String textSegment, TextStyle defaultStyle) {
    final List<TextSpan> spans = [];
    final parts = textSegment.split('**');
    final boldStyle = defaultStyle.copyWith(fontWeight: FontWeight.bold);

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty && parts.length > 1) continue;

      if (i % 2 == 1) {
        spans.add(TextSpan(text: parts[i], style: boldStyle));
      } else {
        spans.add(TextSpan(text: parts[i], style: defaultStyle));
      }
    }
    return spans;
  }

  // --- Main Function to Build Spans (Icons + Bold) ---
  List<InlineSpan> _buildFormattedTextSpans(String text, BuildContext context) {
    final List<InlineSpan> spans = [];
    final defaultStyle = DefaultTextStyle.of(context).style;

    // --- Icon Handling Data (for Bot messages only) ---
    IconData? foundIconData;
    String textBeforeKeyword = "";
    String textAfterKeyword = "";
    bool keywordFound = false;

    if (!isUserMessage) {
      final Map<String, IconData> keywordIcons = {
        // Keywords should be lowercase for regex matching
        "identification of issue": Icons.search,
        "description": Icons.info_outline,
        "symptoms": Icons.warning_amber_rounded,
        "disease management": Icons.healing,
        "management": Icons.healing,
        "solution": Icons.lightbulb_outline,
      };

      // Regex to find "**[Optional Number]. Keyword:**" pattern, case-insensitive
      // It captures the keyword part (like "identification of issue") in group 1
      final keywordPattern = r"\*\*(?:\d+\.\s*)?(" +
          keywordIcons.keys.join("|") + // Creates (key1|key2|...)
          r"):\*\*(.*)"; // Added (.*) to potentially capture rest of line if needed

      final regex = RegExp(keywordPattern,
          caseSensitive: false, multiLine: true); // Use multiLine
      final match = regex.firstMatch(text);

      if (match != null) {
        keywordFound = true;
        // Extract the matched keyword (Group 1) and convert to lowercase
        final matchedKeyword = match.group(1)?.toLowerCase() ?? "";

        // Find the icon data
        foundIconData = keywordIcons[matchedKeyword];

        // Get text before and after the full matched pattern (e.g., "**1. Symptoms:**")
        textBeforeKeyword = text.substring(0, match.start);
        textAfterKeyword =
            text.substring(match.end); // Text after the matched pattern
      }
    }

    // --- Assemble Spans ---
    if (keywordFound && foundIconData != null) {
      // 1. Add Icon (if found)
      spans.add(WidgetSpan(
        child: Icon(foundIconData,
            size: (defaultStyle.fontSize ?? 16.0) * 1.1,
            color: Colors.green[800]), // Slightly larger icon
        alignment: PlaceholderAlignment.middle,
      ));
      spans.add(
          const WidgetSpan(child: SizedBox(width: 8.0))); // Space after icon

      // 2. Parse text *before* the keyword pattern for bold
      spans.addAll(_parseBoldText(textBeforeKeyword, defaultStyle));

      // 3. Add the keyword text itself (extracted from match, maybe style differently?)
      // We can actually skip explicitly adding the keyword text if it's part of textBeforeKeyword or After
      // Let's assume the bold parsing handles it. We just ensure the icon is added.

      // 4. Parse text *after* the keyword pattern for bold
      spans.addAll(_parseBoldText(textAfterKeyword, defaultStyle));
    } else {
      // No keyword found (or it's a user message), parse the whole text for bold only
      spans.addAll(_parseBoldText(text, defaultStyle));
    }

    // Ensure we always return at least an empty span if text was empty
    if (spans.isEmpty && text.isEmpty) {
      spans.add(const TextSpan(text: ''));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final messageTextStyle = isUserMessage
        ? textTheme.bodyMedium?.copyWith(color: Colors.black87)
        : textTheme.bodyMedium?.copyWith(color: Colors.black87);

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            color: isUserMessage ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2.0,
                offset: const Offset(0, 1),
              )
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Keep content left-aligned inside bubble
          mainAxisSize: MainAxisSize.min, // Bubble size wraps content
          children: [
            // Image
            if (imageFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.file(imageFile!,
                      width: 200, height: 200, fit: BoxFit.cover),
                ),
              ),

            // Formatted Text
            if (text.isNotEmpty)
              RichText(
                text: TextSpan(
                  style: messageTextStyle, // Base style for all spans
                  children: _buildFormattedTextSpans(text, context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
