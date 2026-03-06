import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
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

  // Load chatbot.html from assets
  Future<void> _loadHtml() async {
    String content = await rootBundle.loadString('assets/chatbot.html');
    setState(() {
      htmlContent = content;
    });
  }

  // Mobile load
  Future<void> _loadLocalHtmlToWebView() async {
    String htmlString = await rootBundle.loadString('assets/chatbot.html');
    _controller.loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    // 🌐 WEB
    if (kIsWeb) {
      if (htmlContent == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final iframe = html.IFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..srcdoc = htmlContent;

      ui.platformViewRegistry.registerViewFactory(
        'chatbotIframe',
        (int viewId) => iframe,
      );

      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "AI Chatbot",
            style: TextStyle(color: Colors.white),
          ),
             backgroundColor: const Color.fromARGB(
            177,
            8,
            46,
            92,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // <-- this makes the back arrow white
          ),
        ),
        body: HtmlElementView(viewType: 'chatbotIframe'),
      );
    }

    // 📱 MOBILE
    return Scaffold(
      appBar: AppBar(title: const Text("AI Chatbot")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
