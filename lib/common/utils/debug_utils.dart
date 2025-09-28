import 'package:flutter/material.dart';
import 'package:mpitana/screens/debug/maps_debug_screen.dart';

class DebugUtils {
  static void showDebugMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Debug Menu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text('Maps API Debug'),
              subtitle: const Text('Test Google Maps API and diagnose route issues'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapsDebugScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
  
  static Widget buildDebugFab(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.red,
      onPressed: () => showDebugMenu(context),
      child: const Icon(Icons.bug_report, color: Colors.white),
    );
  }
}