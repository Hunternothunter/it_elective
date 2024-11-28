import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hydroponics/pages/dashboard.dart';
import 'package:hydroponics/pages/controls.dart';
import 'package:hydroponics/pages/report.dart';
import 'package:hydroponics/pages/notifications.dart';
import 'package:hydroponics/pages/auth/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hydroponics',
      theme: ThemeData(primarySwatch: Colors.green),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return MainScreen();
          } else {
            return LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('rememberMe') ?? false;
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    ControlsPage(),
    ReportPage(),
  ];

  String _profilePicture = 'assets/profile_pic.png';
  String _userName = 'Jose Vener Jr Rafael';
  String _userEmail = 'rafaeljosevener@gmail.com';

  // Climatic data availability flag
  bool _climaticDataAvailable = false;

  // Placeholder list of climatic data options
  List<String> _climaticData = ['Loading...']; // Initially loading
  String _selectedClimaticData = 'Loading...';

  // Global key to control Scaffold state
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assigning the global key to the scaffold
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Text(
            //   "Smart-Hydroponics",
            //   style: TextStyle(color: Colors.white),
            // ),

            Expanded(child: Container()), // This will take up the space in between

            // Notification icon that opens the notification page
            GestureDetector(
              onTap: () {
                // Navigate to the NotificationsPage when the notification button is tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.notifications,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),

            // Profile image button
            GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(_profilePicture),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(_profilePicture),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _userName,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _userEmail,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Home'),
              leading: Icon(Icons.home),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Controls'),
              leading: Icon(Icons.settings),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            // Climatic Data Section
            ExpansionTile(
              title: Text('Climatic Data'),
              leading: Icon(Icons.cloud_outlined),
              children: <Widget>[
                // Sub-items for Climatic Data
                ListTile(
                  title: Text('pH Level'),
                  trailing: _climaticDataAvailable
                      ? DropdownButton<String>(
                          value: _selectedClimaticData,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedClimaticData = newValue!;
                            });
                          },
                          items: _climaticData
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      : null,
                  onTap: () {
                    if (!_climaticDataAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Climatic data not available yet.'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('TDS Level'),
                  trailing: _climaticDataAvailable
                      ? DropdownButton<String>(
                          value: _selectedClimaticData,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedClimaticData = newValue!;
                            });
                          },
                          items: _climaticData
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      : null,
                  onTap: () {
                    if (!_climaticDataAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Climatic data not available yet.'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Temperature'),
                  trailing: _climaticDataAvailable
                      ? DropdownButton<String>(
                          value: _selectedClimaticData,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedClimaticData = newValue!;
                            });
                          },
                          items: _climaticData
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      : null,
                  onTap: () {
                    if (!_climaticDataAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Climatic data not available yet.'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Humidity'),
                  trailing: _climaticDataAvailable
                      ? DropdownButton<String>(
                          value: _selectedClimaticData,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedClimaticData = newValue!;
                            });
                          },
                          items: _climaticData
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      : null,
                  onTap: () {
                    if (!_climaticDataAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Climatic data not available yet.'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('EC Level'),
                  trailing: _climaticDataAvailable
                      ? DropdownButton<String>(
                          value: _selectedClimaticData,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedClimaticData = newValue!;
                            });
                          },
                          items: _climaticData
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      : null,
                  onTap: () {
                    if (!_climaticDataAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Climatic data not available yet.'),
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              title: Text('Reports'),
              leading: Icon(Icons.report),
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Controls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // Function to show profile menu when the profile icon is tapped
  void _showProfileMenu(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('View Profile'),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Log out'),
                onTap: () {
                  Navigator.pop(context);
                  // Perform logout action (clear user session, etc.)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
