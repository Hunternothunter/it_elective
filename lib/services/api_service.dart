import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:hydroponics/services/constants.dart';
import 'models.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For storing the base URL

class ApiService {
  // Initially set a default base URL
  String baseUrl = 'http://localhost/hydroponics';

  ApiService() {
    _loadBaseUrl(); // Load the base URL from SharedPreferences when the instance is created
  }

  // Load the base URL from SharedPreferences
  Future<void> _loadBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString('baseUrl') ??
        baseUrl; // Use default if no baseUrl is stored
  }

  // Method to update the base URL and store it in SharedPreferences
  Future<void> updateBaseUrl(String newBaseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'baseUrl', newBaseUrl); // Store the new base URL in SharedPreferences
    baseUrl = newBaseUrl; // Update the baseUrl variable in the ApiService
  }

  // Fetch Hydro Parameters
  Future<HydroParameter> getHydroParameters() async {
    final String url = '$baseUrl/hydro-parameters';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return HydroParameter.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load hydro parameters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching hydro parameters: $e');
    }
  }

  // Fetch Components Control (Growlight, Water Pump)
  Future<List<ComponentControl>> getComponentsControl() async {
    final response = await http.get(Uri.parse('$baseUrl/components-control'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((component) => ComponentControl.fromJson(component))
          .toList();
    } else {
      throw Exception('Failed to load components control');
    }
  }

  // Save Settings
  Future<void> saveSettings({
    required String componentName,
    required String dispenseAmount,
  }) async {
    final body = jsonEncode({
      'componentName': componentName,
      'dispenseAmount': dispenseAmount,
    });
    final String url = '$baseUrl/update_controls';

    print("Request Body: $body"); // Check the request body before sending

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save settings: ${response.body}');
    }
  }

  // Fetch Hydro Data
  Future<List<HydroData>> getHydroData() async {
    final String url = '$baseUrl/fetch_data_source';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response into a list of HydroData objects
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => HydroData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load hydro data');
    }
  }

  // Login function
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String url = '$baseUrl/validate_login.php'; // Endpoint for login

    // Prepare the request body
    final Map<String, String> body = {
      'username': username,
      'password': password,
    };

    try {
      // Send a POST request to the backend API
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body), // Convert the body to JSON
      );

      // Check if the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Decode the JSON response from the backend
        dynamic jsonResponse = json.decode(response.body);

        // Explicitly cast the response to Map<String, dynamic>
        if (jsonResponse is Map<String, dynamic>) {
          return jsonResponse;
        } else {
          return {'error': 'Invalid response format from server'};
        }
      } else {
        // Handle error responses
        dynamic jsonResponse = json.decode(response.body);
        return {
          'error': jsonResponse['error'] ?? 'Login failed, try again later.'
        };
      }
    } catch (e) {
      // Catch any errors during the HTTP request and return an error message
      return {'error': 'Error: $e'};
    }
  }

  Future<List<Notification>> fetchNotifications() async {
    final String url = '$baseUrl/notifications';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}'); // Log the response body

        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Notification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }
}
