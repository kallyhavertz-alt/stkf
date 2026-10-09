import 'package:flutter/material.dart';
import 'db_helper.dart';

class MpesaMessagesScreen extends StatefulWidget {
  const MpesaMessagesScreen({super.key});

  @override
  State<MpesaMessagesScreen> createState() => _MpesaMessagesScreenState();
}

class _MpesaMessagesScreenState extends State<MpesaMessagesScreen> {
  List<Map<String, dynamic>> _messages = [];
  int? _selectedMessageIndex;

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

  Future<void> addIncomingMessage(String body) async {
    await MessageDatabase.instance.insertMessage(
      body,
      DateTime.now().toIso8601String(),
    );
    _loadMessages();
  }

  // Parses raw SMS text and applies underlines to dates and URLs
  Widget _buildFormattedMessageText(String messageText, bool isSelected) {
    final textColor = isSelected ? Colors.black : Colors.white;

    // Pattern 1: Matches M-PESA dates (e.g. "9/10/26 at 11:40 AM" or "09/10/2026 at 9:45 PM")
    // Pattern 2: Matches http/https links (e.g. "http://saf.cx/kWQpy")
    final RegExp combinedPattern = RegExp(
      r'(\d{1,2}/\d{1,2}/\d{2,4}\s+at\s+\d{1,2}:\d{2}\s+(?:AM|PM|am|pm))|(https?://[^\s]+)',
    );

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final Match match in combinedPattern.allMatches(messageText)) {
      // Add preceding plain text
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: messageText.substring(lastMatchEnd, match.start),
            style: TextStyle(color: textColor),
          ),
        );
      }

      // Add underlined Date/Time or Link
      final String matchedText = match.group(0)!;
      spans.add(
        TextSpan(
          text: matchedText,
          style: TextStyle(
            color: textColor,
            decoration: TextDecoration.underline,
            decorationColor: textColor,
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 1.2,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining plain text
    if (lastMatchEnd < messageText.length) {
      spans.add(
        TextSpan(
          text: messageText.substring(lastMatchEnd),
          style: TextStyle(color: textColor),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 17,
          height: 1.35,
        ),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF1B1816);
    const bubbleBg = Color(0xFF2C2523);
    const selectedBg = Colors.white;

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
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedMessageIndex == index;
                  final messageText = _messages[index]['body'] as String;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                  // Dynamic Underlined Content
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: _buildFormattedMessageText(messageText, isSelected),
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