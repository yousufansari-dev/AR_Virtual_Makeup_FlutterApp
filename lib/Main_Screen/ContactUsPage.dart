import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await FirebaseFirestore.instance.collection('contact_messages').add({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        _nameController.clear();
        _emailController.clear();
        _messageController.clear();

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Message Sent ✅'),
              content: const Text(
                'Thank you! We will get back to you shortly.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error ❌'),
              content: Text('Something went wrong: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get in Touch',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Have a question, feedback, or suggestion? Fill out the form below and we will respond as soon as possible.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person,
                            validatorMsg: 'Please enter your name',
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validatorMsg: 'Please enter a valid email',
                            isEmail: true,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _messageController,
                            label: 'Message',
                            icon: Icons.message,
                            maxLines: 5,
                            validatorMsg: 'Please enter your message',
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: const Icon(Icons.send),
                              label: const Text('Send Message'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: const Color.fromARGB(
                                  177,
                                  8,
                                  46,
                                  92,
                                ),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Other Ways to Reach Us:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.email, size: 20, color: Colors.grey),
                            SizedBox(width: 10),
                            Text('support@virtualmakeup.app'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 20, color: Colors.grey),
                            SizedBox(width: 10),
                            Text('+92 300 1234567'),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 10),
                            Text('123, Beauty Street, Karachi, Pakistan'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
              ),
            ),
        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required String validatorMsg,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return validatorMsg;
        if (isEmail && !RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
          return validatorMsg;
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
