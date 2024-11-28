import 'package:flutter/material.dart';
import 'package:hydroponics/services/api_service.dart';
import 'package:hydroponics/services/models.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Stream<HydroParameter> _hydroParameterStream;

  @override
  void initState() {
    super.initState();
    _hydroParameterStream = _createHydroParameterStream();
  }

  Stream<HydroParameter> _createHydroParameterStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 5)); // Refresh every 5 seconds
      yield await ApiService().getHydroParameters();
    }
  }

  // Use the current time as the timestamp
  String _formatTimestamp() {
    DateTime now = DateTime.now(); // Get the current time
    return DateFormat('EEEE, MMMM dd, yyyy hh:mm a').format(now); // Format the current time
  }

  Widget _buildCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.green), // Icon displayed at the top with green color
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 24),
              overflow: TextOverflow.ellipsis, // Add ellipsis to prevent overflow
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              overflow: TextOverflow.ellipsis, // Add ellipsis to prevent overflow
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HydroParameter>(
      stream: _hydroParameterStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final data = snapshot.data!;
          String formattedTimestamp = _formatTimestamp(); // Use current time

          // Debugging print statement to verify the timestamp format
          print("Formatted timestamp: $formattedTimestamp");

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard", // Title "Dashboard"
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                SizedBox(height: 20),
                Text("Readings as of $formattedTimestamp"), // Display current time
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildCard("pH Level", data.ph_Level.toString(), Icons.water),
                    _buildCard("TDS Level", data.tdsLevel.toString(), Icons.water_drop),
                    _buildCard("EC Level", data.ecLevel.toString(), Icons.electric_bolt),
                    _buildCard("Temperature", "${data.airTemperature}°C", Icons.thermostat),
                    _buildCard("Humidity", "${data.airHumidity}%", Icons.water_drop),
                    _buildCard("Water Temperature", "${data.waterTemperature}°C", Icons.thermostat),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  }
}
