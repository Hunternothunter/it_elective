import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hydroponics Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Growlight Status
            ListTile(
              title: Text('Growlight'),
              subtitle: Text('Status: ON'),
              leading: Icon(Icons.lightbulb),
            ),
            // Water Pump Status
            ListTile(
              title: Text('Water Pump'),
              subtitle: Text('Status: OFF'),
              leading: Icon(Icons.water_damage),
            ),
            SizedBox(height: 20),
            // Navigate to Controls
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/controls');
              },
              child: Text('Control Panel'),
            ),
          ],
        ),
      ),
    );
  }
}
