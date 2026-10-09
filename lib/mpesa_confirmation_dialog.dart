import 'package:flutter/material.dart';

Future<bool?> showMpesaConfirmationDialog({
  required BuildContext context,
  required String businessNumber,
  required String recipientName,
  required double amount,
}) {
  final TextEditingController responseController = TextEditingController();

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2C2420), // Dark USSD dialog background matching the image
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pay $businessNumber-$recipientName KSH${amount.toStringAsFixed(2)}. Cost KSH0.00.To continue reply with 1, to STOP reply with 2\n1.Yes\n2.No",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.35,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: responseController,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: const Color(0xFF80CBC4),
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF80CBC4), width: 1.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF80CBC4), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false); // Cancelled
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () {
              final input = responseController.text.trim();
              if (input == "1") {
                Navigator.of(dialogContext).pop(true); // Confirmed Yes
              } else {
                Navigator.of(dialogContext).pop(false); // No / Cancelled
              }
            },
            child: const Text(
              "Send",
              style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14),
            ),
          ),
        ],
      );
    },
  );
}