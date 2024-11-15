import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:hydroponics/services/models.dart'; // Ensure these are implemented
import 'package:hydroponics/services/api_service.dart'; // Ensure these are implemented
import 'package:hydroponics/dashboard.dart'; // Ensure these are implemented
import 'package:hydroponics/controls.dart'; // Ensure these are implemented

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-Hydroponics',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Future<HydroParameter> futureHydroParameters;

  List<Widget> _pages = <Widget>[
    DashboardPage(),
    ControlsPage(),
  ];

  @override
  void initState() {
    super.initState();
    futureHydroParameters = ApiService().getHydroParameters(); // Fetch hydro parameters from API or local database
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Smart-Hydroponics',
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            GestureDetector(
              onTap: () => _showProfileDropdown(context),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
                radius: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: _selectedIndex == 0
            ? FutureBuilder<HydroParameter>(
                future: futureHydroParameters,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    HydroParameter data = snapshot.data!;

                    // Parse and format the timestamp dynamically
                    DateTime timestamp;
                    try {
                      // Attempt to parse the timestamp (ISO 8601 or custom format)
                      if (data.timestamp.contains('T')) {
                        // ISO 8601 format (with or without Z)
                        String cleanedTimestamp = data.timestamp.replaceAll("Z", "");
                        timestamp = DateTime.parse(cleanedTimestamp);
                      } else {
                        // Custom format (e.g., 16/11/2023 12:34:56)
                        DateFormat format = DateFormat('dd/MM/yyyy HH:mm:ss');
                        timestamp = format.parse(data.timestamp);
                      }
                    } catch (e) {
                      print("Error parsing timestamp: $e");
                      timestamp = DateTime.now(); // Fallback to current date/time
                    }

                    // Format the timestamp into a more readable string
                    String formattedTimestamp = DateFormat('EEEE, MMMM dd, yyyy, hh:mm a').format(timestamp);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dashboard",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(height: 20),
                          // Display the formatted timestamp
                          Text(
                            "Readings as of $formattedTimestamp",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey),
                          ),
                          SizedBox(height: 20),
                          // Grid of hydroponic data
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 16.0,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              children: [
                                _buildCard(Icons.water, 'pH Level', data.pHLevel),
                                _buildCard(Icons.opacity, 'TDS Level', data.tdsLevel),
                                _buildCard(Icons.analytics, 'EC Level', data.ecLevel),
                                _buildCard(Icons.thermostat_outlined, 'Temperature', '${data.airTemperature}°C'),
                                _buildCard(Icons.cloud, 'Relative Humidity', '${data.airHumidity}%'),
                                _buildCard(Icons.thermostat, 'Water Temperature', '${data.waterTemperature}°C'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Text('No data available');
                  }
                },
              )
            : _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: 'Controls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Jose Vener Rafael"),
              accountEmail: Text("rafaeljosevener@gmail.com"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Controls'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ExpansionTile(
              title: Text('Climatic Data'),
              children: <Widget>[
                ListTile(
                  title: Text('pH Level'),
                  onTap: () {
                    // Handle fetching pH level
                  },
                ),
                ListTile(
                  title: Text('TDS Level'),
                  onTap: () {
                    // Handle fetching TDS level
                  },
                ),
                ListTile(
                  title: Text('Temperature'),
                  onTap: () {
                    // Handle fetching temperature
                  },
                ),
                ListTile(
                  title: Text('Humidity'),
                  onTap: () {
                    // Handle fetching humidity
                  },
                ),
                ListTile(
                  title: Text('EC Level'),
                  onTap: () {
                    // Handle fetching EC level
                  },
                ),
              ],
            ),
            ListTile(
              title: Text('Reports'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, dynamic value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.green,
            ),
            SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(fontSize: 20, color: Colors.green),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Profile Options'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Profile'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
