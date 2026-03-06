// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Web-specific imports
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class SkinToneAnalyzerPage extends StatefulWidget {
  const SkinToneAnalyzerPage({super.key});

  @override
  State<SkinToneAnalyzerPage> createState() => _SkinToneAnalyzerPageState();
}

class _SkinToneAnalyzerPageState extends State<SkinToneAnalyzerPage> {
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

  // Load HTML file content from assets
  Future<void> _loadHtml() async {
    String content = await rootBundle.loadString(
      'assets/skintoneanalyzer.html',
    );
    setState(() {
      htmlContent = content;
    });
  }

  // Load HTML into WebView for mobile platforms
  Future<void> _loadLocalHtmlToWebView() async {
    String htmlString = await rootBundle.loadString(
      'assets/skintoneanalyzer.html',
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
        ..srcdoc = htmlContent; // inject HTML content directly

      // Register iframe for Flutter Web
      ui.platformViewRegistry.registerViewFactory(
        'skintoneIframe',
        (int viewId) => iframe,
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "AI Skin Tone Analyzer",
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
        body: HtmlElementView(viewType: 'skintoneIframe'),
      );
    }

    // Mobile / Android / iOS
    return Scaffold(
      appBar: AppBar(title: const Text("AI Skin Tone Analyzer")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
