import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'PA Recorder',
                applicationVersion: '1.0.0', // You might want to get this dynamically
                applicationLegalese: '© 2025 Your Company Name', // Replace with actual legalese
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text('A simple application to record physical activity.'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
