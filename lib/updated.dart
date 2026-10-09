/*
import 'package:flutter/material.dart';
import 'db_helper.dart';

class MpesaMessagesScreen extends StatefulWidget {
  const MpesaMessagesScreen({super.key});

  @override
  State<MpesaMessagesScreen> createState() => _MpesaMessagesScreenState();
}

class _MpesaMessagesScreenState extends State<MpesaMessagesScreen> {
  List<Map<String, dynamic>> _messages = [];
  int? _selectedMessageIndex; // Track long-pressed item

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await MessageDatabase.instance.getMessages();
    setState(() {
      _messages = data;
    });
  }

  // Callable method when FCM push notification arrives from backend
  Future<void> addIncomingMessage(String body) async {
    await MessageDatabase.instance.insertMessage(
      body,
      DateTime.now().toIso8601String(),
    );
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF1B1816); // Match dark brown/black chat background
    const bubbleBg = Color(0xFF2C2523); // Message bubble background
    const selectedBg = Colors.white; // Highlighting color on long press

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.amber.shade600,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'MPESA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Clear selection when tapping anywhere outside
                if (_selectedMessageIndex != null) {
                  setState(() => _selectedMessageIndex = null);
                }
              },
              child: _messages.isEmpty
                  ? const Center(
                child: Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                reverse: true, // Newest messages at bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedMessageIndex == index;
                  final messageText = _messages[index]['body'] as String;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Message Bubble container
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _selectedMessageIndex = isSelected ? null : index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: isSelected ? selectedBg : bubbleBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text Content
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      messageText,
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white,
                                        fontSize: 17,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  // Safaricom Banner Asset
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    child: Image.asset(
                                      'assets/safaricom.png',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback placeholder widget if asset is missing
                                        return Container(
                                          height: 120,
                                          color: const Color(0xFF2EA152),
                                          child: const Center(
                                            child: Text(
                                              'Safaricom | m-pesa',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Share/Forward Icon Button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38, width: 1.2),
                            ),
                            child: const Icon(
                              Icons.shortcut_rounded,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        const Spacer(flex: 1),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Bottom Disclaimer Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF110E0D),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(color: Colors.white70, fontSize: 13),
                children: [
                  TextSpan(text: "Sender can't accept replies. Contact them directly. "),
                  TextSpan(
                    text: 'Learn more',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 */