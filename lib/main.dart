import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stk/safaricom_plus.dart';
import 'Lipa_na_mpesa_flow.dart';
import '/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StkApp());

  // Initialize notifications asynchronously so the app launches instantly without freezing at the launch icon
  FCMNotificationService.initialize().catchError((error) {
    debugPrint('Error initializing FCM Notification Service: $error');
  });
}

class StkApp extends StatelessWidget {
  const StkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIM ToolKit',
      navigatorKey: FCMNotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        dividerColor: Colors.black26,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF222222), // Classic STK dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF222222),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        dividerColor: Colors.white24,
      ),
      home: const RootSafaricomScreen(),
    );
  }
}

class RootSafaricomScreen extends StatelessWidget {
  const RootSafaricomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safaricom'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(
            title: 'Safaricom+',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SafaricomPlusMainMenuScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'M-PESA',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MpesaMainMenuScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class MpesaMainMenuScreen extends StatelessWidget {
  const MpesaMainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM ToolKit'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(title: 'Send Money', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Withdraw Cash', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Buy Airtime', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Loans and Savings', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'Lipa na M-PESA',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LipaNaMpesaScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'My Account', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class LipaNaMpesaScreen extends StatelessWidget {
  const LipaNaMpesaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lipa na M-PESA'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(
            title: 'Pay Bill',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PayBillSelectOptionScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'Buy Goods and Services',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyGoodsSequenceFlow()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'Pochi la Biashara',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PochiLaBiasharaSequenceFlow()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class PayBillSelectOptionScreen extends StatelessWidget {
  const PayBillSelectOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Bill'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(
            title: 'Search SIM Contacts',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No SIM contacts found')),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'Enter business no.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PayBillSequenceFlow()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class PayBillSequenceFlow extends StatefulWidget {
  const PayBillSequenceFlow({super.key});

  @override
  State<PayBillSequenceFlow> createState() => _PayBillSequenceFlowState();
}

class _PayBillSequenceFlowState extends State<PayBillSequenceFlow> {
  int _currentStep = 0; // 0: BusinessNo, 1: AccountNoMenu, 2: AccountNo, 3: Amount, 4: RecipientName, 5: PIN

  String _businessNumber = '';
  String _accountNumber = '';
  String _amount = '';
  String _recipientName = '';
  String _pin = '';

  bool _isLoading = false;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  // Final Step: Execute Spring Boot API Call
  Future<void> _submitTransaction() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.16.200.58:8081/api/v1/payments/paybill'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'businessNumber': _businessNumber,
          'accountNumber': _accountNumber,
          'amount': double.parse(_amount),
          'recipientName': _recipientName,
          'pin': _pin,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return all the way back to the root screen safely
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction Failed: ${response.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSummaryDialog() {
    final textColor = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Account no.', style: TextStyle(color: textColor, fontSize: 18)),
        content: Text(
          'Pay Bill $_businessNumber Account no. $_accountNumber KSH$_amount',
          style: TextStyle(color: textColor.withAlpha(178), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showUssdConfirmationDialog();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF4DB6AC), fontSize: 16)),
          ),
        ],
      ),
    );
  }
  void _showUssdConfirmationDialog() {
    final TextEditingController ussdInputController = TextEditingController();

    final merchantText = _recipientName.isNotEmpty
        ? '$_businessNumber-$_recipientName'
        : _businessNumber;

    final parsedAmount = double.tryParse(_amount) ?? 0.0;
    final formattedAmount = parsedAmount.toStringAsFixed(2);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2C2420), // Dark SIM Toolkit USSD background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pay $merchantText KSH$formattedAmount. Cost KSH0.00.To continue reply with 1, to STOP reply with 2\n1.Yes\n2.No",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                height: 1.35,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ussdInputController,
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
              Navigator.pop(dialogContext);
              Navigator.of(context).popUntil((route) => route.isFirst); // Cancel transaction
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              final choice = ussdInputController.text.trim();
              Navigator.pop(dialogContext);

              if (choice == '1') {
                _submitTransaction(); // Send payload to Spring Boot
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction cancelled.'),
                    backgroundColor: Colors.orange,
                  ),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: const Text('Send', style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14)),
          ),
        ],
      ),
    );
  }

  /*void _showYesNoDialog() {
    final textColor = Theme.of(context).colorScheme.onSurface;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Pay Bill $_businessNumber Account no. $_accountNumber KSH$_amount\n1. Yes\n2. No',
          style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
        ),
        content: _isLoading
            ? const SizedBox(
          height: 40,
          child: Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC))),
        )
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
              Navigator.pop(dialogContext);
              _submitTransaction();
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF4DB6AC), fontSize: 14)),
          ),
        ],
      ),
    );
  }

   */

  @override
  Widget build(BuildContext context) {
    // Step 0: Enter Business No. Screen
    if (_currentStep == 0) {
      return StkInputPromptScreen(
        key: const ValueKey('step_business_no'),
        title: 'Enter business no.',
        isNumeric: true,
        maxLength: 20,
        onOk: (val) {
          _businessNumber = val;
          _nextStep();
        },
        onCancel: () => Navigator.pop(context),
      );
    }

    // Step 1: Submenu for Account Selection
    if (_currentStep == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pay Bill'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          children: [
            _StkMenuItem(
              title: 'Search SIM Contacts',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No SIM contacts found')),
                );
              },
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            _StkMenuItem(
              title: 'Account no.',
              onTap: () {
                _nextStep();
              },
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
          ],
        ),
      );
    }

    // Step 2: Enter Account No. Screen
    if (_currentStep == 2) {
      return StkInputPromptScreen(
        key: const ValueKey('step_account_no'),
        title: 'Enter account no.',
        isNumeric: false,
        maxLength: 20,
        onOk: (val) {
          _accountNumber = val;
          _nextStep();
        },
        onCancel: () {
          setState(() {
            _currentStep = 1;
          });
        },
      );
    }

    // Step 3: Enter Amount Screen
    if (_currentStep == 3) {
      return StkInputPromptScreen(
        key: const ValueKey('step_amount'),
        title: 'Enter amount',
        isNumeric: true,
        maxLength: 10,
        onOk: (val) {
          _amount = val;
          _nextStep();
        },
        onCancel: () {
          setState(() {
            _currentStep = 2;
          });
        },
      );
    }

    // Step 4: Enter Recipient Name Screen (Optional)
    if (_currentStep == 4) {
      return StkInputPromptScreen(
        key: const ValueKey('step_recipient_name'),
        title: 'Enter recipient name',
        isNumeric: false,
        isOptional: true,
        maxLength: 30,
        onOk: (val) {
          _recipientName = val;
          _nextStep();
        },
        onCancel: () {
          setState(() {
            _currentStep = 3;
          });
        },
      );
    }

    // Step 5: Enter M-PESA PIN Screen
    if (_currentStep == 5) {
      return StkInputPromptScreen(
        key: const ValueKey('step_pin'),
        title: 'Enter M-PESA PIN',
        isObscure: true,
        isNumeric: true,
        maxLength: 4,
        onOk: (val) {
          _pin = val;
          _showSummaryDialog();
        },
        onCancel: () {
          setState(() {
            _currentStep = 4;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _StkMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _StkMenuItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}