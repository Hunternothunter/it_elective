import 'package:flutter/material.dart';
import 'package:hydroponics/services/api_service.dart';
import 'package:hydroponics/services/models.dart';
import 'dart:async';

class ControlsPage extends StatefulWidget {
  @override
  _ControlsPageState createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool isGrowlightOn = false;
  bool isWaterPumpOn = false;
  bool isGrowlightTimeVisible = false;
  bool isWaterPumpTimeVisible = false;

  final TextEditingController growlightHoursController =
      TextEditingController();
  final TextEditingController growlightMinutesController =
      TextEditingController();
  final TextEditingController waterPumpHoursController =
      TextEditingController();
  final TextEditingController waterPumpMinutesController =
      TextEditingController();

  final ApiService apiService = ApiService();

  // Variable to hold the future result of the component data fetch
  late Future<List<dynamic>> futureComponentsControl;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Initialize the future data fetch
    _fetchComponentControlData();
    futureComponentsControl = apiService.getComponentsControl();
    _startPeriodicFetch();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _fetchComponentControlData(); // Fetch data every second
      print(_timer);
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  // Fetch component control data from the API
  Future<void> _fetchComponentControlData() async {
    try {
      List<ComponentControl> components =
          await ApiService().getComponentsControl();

      // Find the component for growlight and water pump
      final growlightComponent = components.firstWhere(
        (component) => component.componentName.toLowerCase() == 'growlight',
        orElse: () => ComponentControl(
            componentName: 'growLight',
            dispenseAmount: 0), // Default if not found
      );

      final waterPumpComponent = components.firstWhere(
        (component) => component.componentName.toLowerCase() == 'waterpump',
        orElse: () => ComponentControl(
            componentName: 'waterPump',
            dispenseAmount: 0), // Default if not found
      );

      setState(() {
        // Update the boolean flags based on dispenseAmount
        isGrowlightOn = growlightComponent.dispenseAmount > 0;
        isWaterPumpOn = waterPumpComponent.dispenseAmount > 0;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> saveSettings(
      String componentName, int hours, int minutes) async {
    try {
      await apiService.saveSettings(
        componentName: componentName,
        dispenseAmount: ((hours * 3600) + (minutes * 60)).toString(),
      );

      setState(() {
        if (componentName == "growLight") {
          isGrowlightOn = true;
          growlightHoursController.clear();
          growlightMinutesController.clear();
          isGrowlightTimeVisible = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Turned on Grow Lights!'),
              duration: Duration(seconds: 1),
            ),
          );
        } else if (componentName == "waterPump") {
          isWaterPumpOn = true;
          waterPumpHoursController.clear();
          waterPumpMinutesController.clear();
          isWaterPumpTimeVisible = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Turned on Water Pump!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save settings. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void validateAndProceed(String componentName, int hours, int minutes) {
    if (hours < 0 || minutes < 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text('Value must be non-negative.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (hours <= 0 && minutes <= 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Invalid Input'),
          content: Text(
              'At least one value (hours or minutes) must be greater than zero.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    String tempComponentName = "";

    if (componentName == "growLight") {
      tempComponentName = "Grow Lights";
    }
    if (componentName == "waterPump") {
      tempComponentName = "Water Pump";
    }
    // Proceed with saving settings after confirmation
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm Changes'),
        content: Text(
            'Are you sure you want to save the changes for $tempComponentName?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              saveSettings(componentName, hours, minutes);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Function for confirmation of the switch toggle action
  void showConfirmationDialog(String componentName, bool value) {
    String tempComponentName = "";

    if (componentName == "growlight") {
      tempComponentName = "Grow Lights";
    }
    if (componentName == "waterpump") {
      tempComponentName = "Water Pump";
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${value ? "Turn on" : "Turn off"}'),
        content: Text(
            'Are you sure you want to ${value ? 'turn on' : 'turn off'} $tempComponentName?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (componentName == "growlight") {
                  isGrowlightOn = value;
                }
                if (componentName == "waterpump") {
                  isWaterPumpOn = value;
                }
              });

              Navigator.pop(context); // Close the dialog

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${value ? 'Turned on' : 'Turned off'} $tempComponentName!'),
                  duration: Duration(seconds: 1),
                ),
              );

              if (value) {
                saveSettings(componentName, 18, 0);
              } else {
                saveSettings(componentName, 0, 0);
              }
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Control Panel",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureComponentsControl, // Your data fetching function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No components available.'));
          } else {
            // Handle the data here
            dynamic data = snapshot.data!;
            print("Received Data: " + data.toString());

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Growlights Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Material(
                              color: isGrowlightTimeVisible
                                  ? Colors.red
                                  : Colors.green,
                              shape: CircleBorder(),
                              child: IconButton(
                                icon: Icon(
                                    isGrowlightTimeVisible
                                        ? Icons.remove
                                        : Icons.add,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    isGrowlightTimeVisible =
                                        !isGrowlightTimeVisible;
                                  });
                                },
                              ),
                            ),
                            title: Text('Growlights'),
                            trailing: Switch(
                              value: isGrowlightOn,
                              onChanged: (value) {
                                showConfirmationDialog("growlight", value);
                              },
                            ),
                          ),
                          if (isGrowlightTimeVisible) ...[
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: growlightHoursController,
                              decoration: InputDecoration(
                                labelText: 'Hours',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: growlightMinutesController,
                              decoration: InputDecoration(
                                labelText: 'Minutes',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                int hours = int.tryParse(
                                        growlightHoursController.text) ??
                                    0;
                                int minutes = int.tryParse(
                                        growlightMinutesController.text) ??
                                    0;
                                validateAndProceed("growLight", hours, minutes);
                              },
                              child: Text('Save Changes'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Water Pump Section
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Material(
                              color: isWaterPumpTimeVisible
                                  ? Colors.red
                                  : Colors.green,
                              shape: CircleBorder(),
                              child: IconButton(
                                icon: Icon(
                                    isWaterPumpTimeVisible
                                        ? Icons.remove
                                        : Icons.add,
                                    color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    isWaterPumpTimeVisible =
                                        !isWaterPumpTimeVisible;
                                  });
                                },
                              ),
                            ),
                            title: Text('Water Pump'),
                            trailing: Switch(
                              value: isWaterPumpOn,
                              onChanged: (value) {
                                showConfirmationDialog("waterpump", value);
                              },
                            ),
                          ),
                          if (isWaterPumpTimeVisible) ...[
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: waterPumpHoursController,
                              decoration: InputDecoration(
                                labelText: 'Hours',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: waterPumpMinutesController,
                              decoration: InputDecoration(
                                labelText: 'Minutes',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                int hours = int.tryParse(
                                        waterPumpHoursController.text) ??
                                    0;
                                int minutes = int.tryParse(
                                        waterPumpMinutesController.text) ??
                                    0;
                                validateAndProceed("waterPump", hours, minutes);
                              },
                              child: Text('Save Changes'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
