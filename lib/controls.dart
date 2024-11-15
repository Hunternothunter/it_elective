import 'package:flutter/material.dart';

class ControlsPage extends StatefulWidget {
  @override
  _ControlsPageState createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool isGrowlightOn = false;
  bool isWaterPumpOn = false;
  bool isGrowlightTimeVisible = false;
  bool isWaterPumpTimeVisible = false;
  final TextEditingController growlightHoursController = TextEditingController();
  final TextEditingController growlightMinutesController = TextEditingController();
  final TextEditingController waterPumpHoursController = TextEditingController();
  final TextEditingController waterPumpMinutesController = TextEditingController();

  // Helper function for input validation
  String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    final int? parsedValue = int.tryParse(value);
    if (parsedValue == null || parsedValue < 0 || parsedValue > 23) {
      return 'Please enter a valid number between 0 and 23';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Control Panel", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),),
      ),
      body: SingleChildScrollView(  // Wrap the body with SingleChildScrollView
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Growlight control card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Growlight control toggle with plus icon to the left
                    ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              isGrowlightTimeVisible = !isGrowlightTimeVisible;
                            });
                          },
                        ),
                      ),
                      title: Text('Growlights'),
                      trailing: Switch(
                        value: isGrowlightOn,
                        onChanged: (bool value) {
                          setState(() {
                            isGrowlightOn = value;
                          });
                        },
                      ),
                    ),
                    // Expandable section for Growlight time input
                    if (isGrowlightTimeVisible) ...[
                      TextFormField(
                        controller: growlightHoursController,
                        decoration: InputDecoration(labelText: 'Hours'),
                        keyboardType: TextInputType.number,
                        validator: (value) => validateTime(value),
                      ),
                      TextFormField(
                        controller: growlightMinutesController,
                        decoration: InputDecoration(labelText: 'Minutes'),
                        keyboardType: TextInputType.number,
                        validator: (value) => validateTime(value),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Save Growlight settings
                          if (growlightHoursController.text.isNotEmpty &&
                              growlightMinutesController.text.isNotEmpty) {
                            // Validate input and save
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Settings Saved'),
                                content: Text('Your changes have been saved.'),
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
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Water Pump control card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Water Pump control toggle with plus icon to the left
                    ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              isWaterPumpTimeVisible = !isWaterPumpTimeVisible;
                            });
                          },
                        ),
                      ),
                      title: Text('Water Pump'),
                      trailing: Switch(
                        value: isWaterPumpOn,
                        onChanged: (bool value) {
                          setState(() {
                            isWaterPumpOn = value;
                          });
                        },
                      ),
                    ),
                    // Expandable section for Water Pump time input
                    if (isWaterPumpTimeVisible) ...[
                      TextFormField(
                        controller: waterPumpHoursController,
                        decoration: InputDecoration(labelText: 'Hours'),
                        keyboardType: TextInputType.number,
                        validator: (value) => validateTime(value),
                      ),
                      TextFormField(
                        controller: waterPumpMinutesController,
                        decoration: InputDecoration(labelText: 'Minutes'),
                        keyboardType: TextInputType.number,
                        validator: (value) => validateTime(value),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Save Water Pump settings
                          if (waterPumpHoursController.text.isNotEmpty &&
                              waterPumpMinutesController.text.isNotEmpty) {
                            // Validate input and save
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Settings Saved'),
                                content: Text('Your changes have been saved.'),
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
                        },
                        child: Text('Save Changes'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
