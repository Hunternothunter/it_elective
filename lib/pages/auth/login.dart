import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydroponics/pages/main.dart'; // Replace with actual import for your MainScreen
import 'package:hydroponics/services/api_service.dart'; // Import your ApiService
import 'package:hydroponics/screens/settings.dart'; // Import your SettingsPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isBiometricAuthInProgress = false; // Track biometric authentication state
  bool _obscurePassword = true; // Track whether the password is obscured or visible
  final LocalAuthentication auth = LocalAuthentication();
  final ApiService _apiService = ApiService(); // Initialize the ApiService

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  // Load "Remember Me" preferences from SharedPreferences
  void _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('username') ?? '';
      }
    });
  }

  // Save "Remember Me" preferences to SharedPreferences
  void _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      prefs.setString('username', _usernameController.text);
    } else {
      prefs.remove('username');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      setState(() {
        _isBiometricAuthInProgress = true;
      });

      bool canAuthenticate = await auth.canCheckBiometrics;
      if (!canAuthenticate) {
        setState(() {
          _isBiometricAuthInProgress = false;
        });
        _showSnackBar('Biometric authentication is not available on this device.');
        return;
      }

      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        setState(() {
          _isBiometricAuthInProgress = false;
        });
        _showSnackBar('No biometrics enrolled on this device.');
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Please place your finger on the scanner to authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      setState(() {
        _isBiometricAuthInProgress = false;
      });

      if (authenticated) {
        _saveRememberMe(); // Save "Remember Me" preferences after successful biometric login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        _showSnackBar('Authentication failed. Please try again.');
      }
    } catch (e) {
      setState(() {
        _isBiometricAuthInProgress = false;
      });
      print('Error with biometrics: $e');
      _showSnackBar('Biometric authentication failed.');
    }
  }

  // Perform login validation by calling API
  void _login() async {
    try {
      final response = await _apiService.login(
        _usernameController.text,
        _passwordController.text,
      );

      // If the response contains an error
      if (response.containsKey('error')) {
        _showSnackBar(response['error']);
      } else {
        // If login is successful, save preferences and navigate to the main screen
        _saveRememberMe(); // Optionally save "Remember Me" preferences
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      _showSnackBar('Login failed: $e');
    }
  }

  // Helper method to display a snack bar with a message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures the layout adjusts when the keyboard appears
      appBar: AppBar(
        title: const Text(
          'Smart-Hydroponics',
          style: TextStyle(
            color: Colors.green,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to SettingsPage when the settings icon is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Makes the body scrollable to prevent overflow when the keyboard is shown
        child: Center( // Centers the content horizontally and vertically
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centers the Card vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
              children: [ 
                // Card to wrap the textfields, checkbox, and login button
                SizedBox(height: 100), // Optional: Add top padding if needed
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Username field
                        TextField(
                          controller: _usernameController,
                          decoration: const InputDecoration(labelText: 'Username'),
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword, // Dynamically control visibility
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword; // Toggle password visibility
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Remember Me checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            const Text('Remember Me'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Login button with green color and matching width inside the card
                        SizedBox(
                          width: double.infinity, // Makes the button as wide as the text fields
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                              ),
                              minimumSize: Size(double.infinity, 50), // Adjust height and width
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white, // Text color
                                fontSize: 16, // Text size
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Fingerprint authentication button
                        // ElevatedButton.icon(
                        //   onPressed: _authenticateWithBiometrics,
                        //   icon: const Icon(Icons.fingerprint),
                        //   label: const Text('Login with Fingerprint'),
                        // ),
                        // if (_isBiometricAuthInProgress)
                        //   const Padding(
                        //     padding: EdgeInsets.all(8.0),
                        //     child: CircularProgressIndicator(),
                        //   ), // Show progress indicator while authenticating
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
