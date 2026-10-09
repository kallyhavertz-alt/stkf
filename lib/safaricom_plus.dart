import 'package:flutter/material.dart';
import 'mpesa_messages_screen.dart';

class SafaricomPlusMainMenuScreen extends StatelessWidget {
  const SafaricomPlusMainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM ToolKit'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(
            title: 'My Account',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My Account option selected')),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'M-Banking Services',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MBankingServicesScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class MBankingServicesScreen extends StatelessWidget {
  const MBankingServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Banking Services'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(title: 'Barclays Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Co-op Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'DTB', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Ecobank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Equity Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Family Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Faulu DTM', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'First Community', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'I&M Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'More ...',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MBankingMoreScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
  }
}

class MBankingMoreScreen extends StatelessWidget {
  const MBankingMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Banking Services'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          _StkMenuItem(title: 'KCB', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'KWFT', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'M-SACCO', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'National Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'NIC Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(
            title: 'Post Bank',
            onTap: () {
              // Directly opens the offline M-PESA messages thread
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MpesaMessagesScreen()),
              );
            },
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Sidian Bank', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          _StkMenuItem(title: 'Standard Chartered', onTap: () {}),
          Divider(height: 1, color: Theme.of(context).dividerColor),
        ],
      ),
    );
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