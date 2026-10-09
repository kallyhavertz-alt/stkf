import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StkMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const StkMenuItem({super.key, required this.title, required this.onTap});

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


class StkInputPromptScreen extends StatefulWidget {
  final String title;
  final bool isObscure;
  final bool isNumeric;
  final int maxLength;
  final ValueChanged<String> onOk;
  final VoidCallback? onCancel;
  final bool isOptional;

  const StkInputPromptScreen({
    super.key,
    required this.title,
    this.isObscure = false,
    this.isNumeric = false,
    this.maxLength = 20,
    required this.onOk,
    this.onCancel,
    this.isOptional = false,
  });

  @override
  State<StkInputPromptScreen> createState() => _StkInputPromptScreenState();
}

class _StkInputPromptScreenState extends State<StkInputPromptScreen> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _charCount = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleOk() {
    if (!widget.isOptional && _controller.text.trim().isEmpty) return;
    widget.onOk(_controller.text.trim());
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                obscureText: widget.isObscure,
                autofocus: true,
                keyboardType: widget.isNumeric ? TextInputType.number : TextInputType.text,
                style: TextStyle(color: textColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Please enter:',
                  hintStyle: TextStyle(color: textColor.withAlpha(97), fontSize: 16),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4DB6AC), width: 1.5),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF4DB6AC), width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$_charCount/${widget.maxLength}',
                  style: TextStyle(color: textColor.withAlpha(138), fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _handleCancel,
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF80CBC4),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                    onPressed: _handleOk,
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuyGoodsSequenceFlow extends StatefulWidget {
  const BuyGoodsSequenceFlow({super.key});

  @override
  State<BuyGoodsSequenceFlow> createState() => _BuyGoodsSequenceFlowState();
}

class _BuyGoodsSequenceFlowState extends State<BuyGoodsSequenceFlow> {
  int _currentStep = 0; // 0: TillNo, 1: Amount, 2: RecipientName, 3: PIN

  String _tillNumber = '';
  String _amount = '';
  String _recipientName = '';
  String _pin = '';

  bool _isLoading = false;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _submitTransaction() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.16.200.58:8081/api/v1/payments/buygoods'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tillNumber': _tillNumber,
          'amount': double.parse(_amount),
          'merchantName': _recipientName,
          'pin': _pin,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction Failed: ${response.body}')),
          );
        }
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
      builder: (context) => AlertDialog(
        title: Text('Buy Goods', style: TextStyle(color: textColor, fontSize: 18)),
        content: Text(
          'Buy Goods to $_tillNumber KSH$_amount',
          style: TextStyle(color: textColor.withAlpha(178), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
        ? '$_tillNumber - $_recipientName'
        : _tillNumber;

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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              final choice = ussdInputController.text.trim();
              Navigator.pop(dialogContext);

              if (choice == '1') {
                _submitTransaction();
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

  @override
  Widget build(BuildContext context) {
    // Step 0: Enter Till No.
    if (_currentStep == 0) {
      return StkInputPromptScreen(
        key: const ValueKey('buygoods_till_no'),
        title: 'Enter Till No.',
        isNumeric: true,
        maxLength: 10,
        onOk: (val) {
          _tillNumber = val;
          _nextStep();
        },
        onCancel: () => Navigator.pop(context),
      );
    }

    //  Enter Amount
    if (_currentStep == 1) {
      return StkInputPromptScreen(
        key: const ValueKey('buygoods_amount'),
        title: 'Enter amount',
        isNumeric: true,
        maxLength: 10,
        onOk: (val) {
          _amount = val;
          _nextStep();
        },
        onCancel: () {
          setState(() {
            _currentStep = 0;
          });
        },
      );
    }

    //  Enter Recipient Name
    if (_currentStep == 2) {
      return StkInputPromptScreen(
        key: const ValueKey('buygoods_recipient_name'),
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
            _currentStep = 1;
          });
        },
      );
    }

    //  Enter M-PESA PIN
    if (_currentStep == 3) {
      return StkInputPromptScreen(
        key: const ValueKey('buygoods_pin'),
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
            _currentStep = 2;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }
}


class PochiLaBiasharaSequenceFlow extends StatefulWidget {
  const PochiLaBiasharaSequenceFlow({super.key});

  @override
  State<PochiLaBiasharaSequenceFlow> createState() => _PochiLaBiasharaSequenceFlowState();
}

class _PochiLaBiasharaSequenceFlowState extends State<PochiLaBiasharaSequenceFlow> {
  int _currentStep = 0; // 0: PhoneNo, 1: Amount, 2: RecipientName, 3: PIN

  String _phoneNumber = '';
  String _amount = '';
  String _recipientName = '';
  String _pin = '';

  bool _isLoading = false;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  Future<void> _submitTransaction() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://172.16.200.58:8081/api/v1/payments/pochi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': _phoneNumber,
          'amount': double.parse(_amount),
          'recipientName': _recipientName,
          'pin': _pin,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transaction Failed: ${response.body}')),
          );
        }
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
      builder: (context) => AlertDialog(
        title: Text('Pochi la Biashara', style: TextStyle(color: textColor, fontSize: 18)),
        content: Text(
          'Send Money to Pochi $_phoneNumber KSH$_amount',
          style: TextStyle(color: textColor.withAlpha(178), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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

    final recipientText = _recipientName.isNotEmpty
        ? '$_phoneNumber - $_recipientName'
        : _phoneNumber;

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
              "Send Money to Pochi $recipientText KSH$formattedAmount. Cost KSH0.00.To continue reply with 1, to STOP reply with 2\n1.Yes\n2.No",
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
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF82B1FF), fontSize: 14)),
          ),
          TextButton(
            onPressed: () {
              final choice = ussdInputController.text.trim();
              Navigator.pop(dialogContext);

              if (choice == '1') {
                _submitTransaction();
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

  @override
  Widget build(BuildContext context) {
    // Step 0: Enter Mobile No.
    if (_currentStep == 0) {
      return StkInputPromptScreen(
        key: const ValueKey('pochi_phone_no'),
        title: 'Enter Mobile No.',
        isNumeric: true,
        maxLength: 12,
        onOk: (val) {
          _phoneNumber = val;
          _nextStep();
        },
        onCancel: () => Navigator.pop(context),
      );
    }

    // Step 1: Enter Amount
    if (_currentStep == 1) {
      return StkInputPromptScreen(
        key: const ValueKey('pochi_amount'),
        title: 'Enter amount',
        isNumeric: true,
        maxLength: 10,
        onOk: (val) {
          _amount = val;
          _nextStep();
        },
        onCancel: () {
          setState(() {
            _currentStep = 0;
          });
        },
      );
    }

    // Step 2: Enter Recipient Name
    if (_currentStep == 2) {
      return StkInputPromptScreen(
        key: const ValueKey('pochi_recipient_name'),
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
            _currentStep = 1;
          });
        },
      );
    }

    // Step 3: Enter M-PESA PIN
    if (_currentStep == 3) {
      return StkInputPromptScreen(
        key: const ValueKey('pochi_pin'),
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
            _currentStep = 2;
          });
        },
      );
    }

    return const SizedBox.shrink();
  }
}