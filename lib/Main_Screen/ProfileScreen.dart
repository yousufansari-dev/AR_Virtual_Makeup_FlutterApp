import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String gender = 'male';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        setState(() {
          gender = (doc['gender'] ?? 'male').toString().toLowerCase();
          _nameController.text = (doc['name'] ?? '').toString();
          _mobileController.text = (doc['mobile'] ?? '').toString();

          profileImageUrl = gender == 'male'
              ? 'https://t3.ftcdn.net/jpg/02/00/90/24/360_F_200902415_G4eZ9Ok3Ypd4SZZKjc8nqJyFVp1eOD6V.jpg'
              : 'https://st4.depositphotos.com/13193658/25036/i/450/depositphotos_250363326-stock-photo-smiling-attractive-woman-white-sweater.jpg';
        });
      }
    }
  }

  void _updateProfile() async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.toString().trim(),
        'mobile': _mobileController.text.toString().trim(),
        'gender': gender.toLowerCase(),
      });

      if (_passwordController.text.toString().trim().isNotEmpty) {
        await user.updatePassword(_passwordController.text.toString().trim());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white, // 🔹 Title text white
          ),
        ),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      177,
                      8,
                      46,
                      92,
                    ).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(profileImageUrl),
              ),
            ),
            const SizedBox(height: 25),

            // Form Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      177,
                      8,
                      46,
                      92,
                    ).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Name
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Full Name', Icons.person),
                  ),
                  const SizedBox(height: 15),

                  // Mobile
                  TextField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Mobile Number', Icons.phone),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration('New Password', Icons.lock),
                  ),
                  const SizedBox(height: 15),

                  // Gender
                  DropdownButtonFormField<String>(
                    initialValue: gender,
                    items: ['male', 'female']
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g[0].toUpperCase() + g.substring(1)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          gender = val;
                          profileImageUrl = val == 'male'
                              ? 'https://t3.ftcdn.net/jpg/02/00/90/24/360_F_200902415_G4eZ9Ok3Ypd4SZZKjc8nqJyFVp1eOD6V.jpg'
                              : 'https://st4.depositphotos.com/13193658/25036/i/450/depositphotos_250363326-stock-photo-smiling-attractive-woman-white-sweater.jpg';
                        });
                      }
                    },
                    decoration: _inputDecoration('Gender', Icons.wc),
                  ),
                  const SizedBox(height: 25),

                  // Update Button
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white, // 🔹 Text white
                      ),
                    ),
                  ),
                ],
              ),
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color.fromARGB(177, 8, 46, 92)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }
}
