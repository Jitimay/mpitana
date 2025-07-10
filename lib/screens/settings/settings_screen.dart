import 'package:flutter/material.dart';
import 'package:mpitana/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dark Mode',
              style: TextStyle(fontSize: 24),
            ),
            Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                if (value) {
                  MyApp.of(context)?.toggleTheme(ThemeMode.dark);
                } else {
                  MyApp.of(context)?.toggleTheme(ThemeMode.light);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 