import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showTruecallerMpesaOverlay({
  required BuildContext context,
  required String transactionCode,
  required double amount,
  required String recipientName,
  required String rawSmsText,
  required VoidCallback onMarkAsRead,
}) {
  final String formattedTime = DateFormat('hh:mm a').format(DateTime.now()).toLowerCase();
  final String formattedAmount = 'Ksh${amount.toStringAsFixed(2)}';

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MpesaOverlay',
    barrierColor: Colors.black.withAlpha(128), // Semi-transparent dim background
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E61ED), // Truecaller Header Blue
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. TOP BLUE HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        children: [
                          const Text(
                            'truecaller',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'SMS · $formattedTime',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. INNER BLACK NOTIFICATION CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Colors.black, // Pure black background
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // M-PESA Header Row
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'M-',
                                            style: TextStyle(
                                              color: Color(0xFF00A859),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'PESA',
                                            style: TextStyle(
                                              color: Color(0xFFE53935),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'MPESA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Dynamic Rich Message Body
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                height: 1.35,
                              ),
                              children: [
                                TextSpan(
                                  text: '$transactionCode ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'confirmed. '),
                                TextSpan(
                                  text: '$formattedAmount ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'sent to '),
                                TextSpan(
                                  text: '$recipientName.',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // AI Summary Indicator Row
                          const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF64B5F6),
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'AI summary',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 3. BOTTOM ACTION BAR ("Mark as read")
                    InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        onMarkAsRead();
                      },
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18.0),
                        bottomRight: Radius.circular(18.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0A1C38), // Dark Navy Action Bar
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(18.0),
                            bottomRight: Radius.circular(18.0),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Mark as read',
                            style: TextStyle(
                              color: Color(0xFF64B5F6), // Truecaller Action Blue
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1), // Slide down from top of screen
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}