import 'package:flutter/material.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class AboutPage extends StatefulWidget {
  final String userName;
  final String userImage;

  const AboutPage({super.key, required this.userName, required this.userImage});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final String _aboutText =
      'Welcome to VirtualMakeup — aik friendly jaga jahan aap products explore '
      'kar sakte hain, try kar sakte hain aur apna order easily track kar sakte hain. '
      'Humari team ka maqsad simple, beautiful aur comfortable experience provide karna hai.';

  /// TEAM DATA
  final List<Map<String, String>> _team = const [
    {
      'name': 'Aiman',
      'role': 'UI/UX Designer',
      'image': 'assets/team/team.PNG',
      'bio': 'Product visuals aur interaction design pe kaam karti hain.',
    },
    {
      'name': 'Ruhma',
      'role': 'Flutter Developer',
      'image': 'assets/team/team.PNG',
      'bio':
          'App architecture, UI logic aur performance optimization karti hain.',
    },
    {
      'name': 'Ramsha',
      'role': 'Backend / Firestore',
      'image': 'assets/team/team.PNG',
      'bio': 'Database, cloud functions aur APIs sambhalti hain.',
    },
    {
      'name': 'Zaib-un-nisa',
      'role': 'QA & Release',
      'image': 'assets/team/team.PNG',
      'bio': 'Testing, bug-fixing aur release pipeline manage karti hain.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ABOUT TITLE
            Text('About Us', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),

            /// ABOUT CARD
            Card(
              elevation: 4,
              shadowColor: const Color.fromARGB(
                177,
                8,
                46,
                92,
              ).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _aboutText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TEAM TITLE
            Text(
              'Meet the Team',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            /// TEAM GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _team.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                return _buildTeamCard(_team[index]);
              },
            ),
          ],
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

  /// TEAM CARD WIDGET (NULL SAFE)
  Widget _buildTeamCard(Map<String, String> member) {
    final String imagePath = member['image'] ?? 'assets/team/team.PNG';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          /// AVATAR
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xffFF7EB3), Color(0xffFF65A3)],
              ),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 76,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// NAME
          Text(
            member['name'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xff082E5C),
            ),
          ),

          /// ROLE
          Text(
            member['role'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 8),

          /// BIO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              member['bio'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
