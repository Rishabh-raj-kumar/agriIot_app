import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewSettings settings = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true, // Allows handling navigation requests
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Flutter's AppBar back button will work correctly!
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Optional: Check if webview can go back internally first
            if (_webViewController != null &&
                await _webViewController!.canGoBack()) {
              _webViewController!.goBack();
            } else {
              // Otherwise, pop the Flutter screen
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text("Object Details"), // Or dynamically set title
        actions: [
          // Optional: Add Refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Optional: Progress Indicator
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              minHeight: 3,
            ),
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                // Handle URL loading start
              },
              onLoadStop: (controller, url) {
                // Handle URL loading stop
              },
              onProgressChanged: (controller, progress) {
                if (!mounted) return;
                setState(() {
                  _progress = progress / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                // Handle loading errors
                print("WebView Error: ${error.description}");
                // Maybe show an error message or pop the screen
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // Decide how to handle navigation requests within the webview
                // Example: Allow all navigation within the webview
                return NavigationActionPolicy.ALLOW;
              },
            ),
          ),
        ],
      ),
    );
  }
}
