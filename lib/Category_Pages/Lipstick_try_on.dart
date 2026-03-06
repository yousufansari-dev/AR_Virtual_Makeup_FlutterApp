import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Web-specific imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LipstickTryNowPage extends StatefulWidget {
  const LipstickTryNowPage({super.key});

  @override
  State<LipstickTryNowPage> createState() => _LipstickTryNowPageState();
}

class _LipstickTryNowPageState extends State<LipstickTryNowPage> {
  late WebViewController _controller;
  String? htmlContent;

  @override
  void initState() {
    super.initState();
    _loadHtml();

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
      _loadLocalHtmlToWebView();
    }
  }

  // Load HTML content from assets
  Future<void> _loadHtml() async {
    String content = await rootBundle.loadString('assets/lipsticktryon.html');
    setState(() {
      htmlContent = content;
    });
  }

  // Load HTML into WebView for mobile platforms
  Future<void> _loadLocalHtmlToWebView() async {
    String htmlString = await rootBundle.loadString(
      'assets/lipsticktryon.html',
    );
    _controller.loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (htmlContent == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = htmlContent; // Inject HTML content directly

      // Register iframe for Flutter Web
      ui.platformViewRegistry.registerViewFactory(
        'lipstickIframe',
        (int viewId) => iframe,
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "AI Lipstick Try-On",
            style: TextStyle(
              color: Colors.white, // yahan text color white set kiya
            ),
          ),
          backgroundColor: const Color.fromARGB(
            177,
            8,
            46,
            92,
          ), // yahan background color set kiya
        ),
        body: HtmlElementView(viewType: 'lipstickIframe'),
      );
    }

    // Mobile / Android / iOS
    return Scaffold(
      appBar: AppBar(title: const Text("AI Lipstick Try-On")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
