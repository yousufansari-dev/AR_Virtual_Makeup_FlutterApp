import 'package:flutter/material.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  // ===== Dummy User Information (Replace with Firestore later) =====
  String get userName => "Guest User";
  String getUserImage() {
    return "https://i.pravatar.cc/150?img=3";
  }

  final List<Map<String, String>> faqs = const [
    {
      'question': 'How can I track my order?',
      'answer':
          'Go to My Orders section and click on the order to see tracking details.',
    },
    {
      'question': 'How do I return a product?',
      'answer':
          'You can request a return from the order details page within 7 days of delivery.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can use the Contact Us page or email support@virtualmakeup.app.',
    },
    {
      'question': 'How to try AR makeup?',
      'answer':
          'Go to the Home Screen and click on the Try Now button to launch AR camera.',
    },
    {
      'question': 'How can I save my favorite products?',
      'answer':
          'Click on the heart icon on any product card to add it to your favorites.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.white, // 🔹 Text white
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(
          177,
          8,
          46,
          92,
        ), // 🔹 Pink background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            final faq = faqs[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faq['answer']!),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(177, 8, 46, 92), // #831843
        child: Text(
          '💄', // Lipstick emoji
          style: TextStyle(fontSize: 24), // make it big enough
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
      ),
    );
  }
}
