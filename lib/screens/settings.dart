import 'package:flutter/material.dart';
import 'package:hydroponics/pages/auth/login.dart';
import 'package:hydroponics/services/api_service.dart'; // Import your ApiService

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _urlController = TextEditingController();
  ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  void initState() {
    super.initState();
    // Set the current URL in the text field
    _urlController.text = apiService.baseUrl; // Read the base URL from ApiService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'Enter your custom API URL',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String newBaseUrl = _urlController.text.trim();
                if (newBaseUrl.isNotEmpty) {
                  await apiService.updateBaseUrl(newBaseUrl); // Update the base URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Base URL updated to: $newBaseUrl')),
                  );
                  Navigator.pop(context);

                  // Navigate to LoginPage after updating base URL
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
