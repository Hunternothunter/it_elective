import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../services/api_service.dart'; // Import ApiService
import '../services/models.dart'; // Import your models.dart

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  List<HydroData> data = []; // List of HydroData
  late _CustomDataTableSource _dataSource;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch data from ApiService
  Future<void> _fetchData() async {
    try {
      List<HydroData> fetchedData = await ApiService().getHydroData();
      setState(() {
        data = fetchedData;
        _dataSource = _CustomDataTableSource(data, _formatTimestamp);
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Generate and export CSV
  Future<void> _exportCSV() async {
    List<List<String>> rows = [
      [
        "ID",
        "pH Level",
        "TDS Level",
        "Temperature",
        "Humidity",
        "EC Level"
        "Water Temperature",
      ]
    ];

    for (var item in data) {
      rows.add([
        item.hydroUuid,
        item.phLevel.toString(),
        item.tdsLevel.toString(),
        item.airTemperature.toString(),
        item.airHumidity.toString(),
        item.ecLevel.toString(),
        item.waterTemperature.toString(),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Get the path to store the file
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/sensor_data.csv";
    File file = File(path);
    await file.writeAsString(csv);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('CSV Exported to $path'),
    ));
  }

  // Format the timestamp (if needed)
  String _formatTimestamp(String timestamp) {
    try {
      DateTime date = DateTime.parse(timestamp); // Default parsing method
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      print("Error parsing timestamp: $e");
      return timestamp; // Return the original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _exportCSV,
          ),
        ],
      ),
      body: data.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    PaginatedDataTable(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Historical Data',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          // IconButton(
                          //   icon: Row(
                          //     children: [
                          //       Text("CSV"),
                          //       Icon(Icons.download),
                          //       SizedBox(width: 5),
                          //     ],
                          //   ),
                          //   onPressed: _exportCSV,
                          // ),
                        ],
                      ),
                      rowsPerPage: 10, // Number of rows per page
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('pH Level')),
                        DataColumn(label: Text('TDS Level')),
                        DataColumn(label: Text('Temperature')),
                        DataColumn(label: Text('Humidity')),
                        DataColumn(label: Text('EC Level')),
                        DataColumn(label: Text('Water Temperature')),
                      ],
                      source: _dataSource,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CustomDataTableSource extends DataTableSource {
  final List<HydroData> data;
  final String Function(String) formatTimestamp;

  _CustomDataTableSource(this.data, this.formatTimestamp);

  @override
  DataRow getRow(int index) {
    final item = data[index];

    // Alternate row colors
    bool isEvenRow = index % 2 == 0;
    Color rowColor = isEvenRow ? Colors.grey[100]! : Colors.white;

    return DataRow(
      color: WidgetStateProperty.all(rowColor),
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150), // Limit width
            child: Text(
              item.hydroUuid,
              softWrap: true, // Enable text wrapping
              overflow: TextOverflow.visible, // Show overflow text
            ),
          ),
        ),
        DataCell(Text(item.phLevel.toString())),
        DataCell(Text(item.tdsLevel.toString())),
        DataCell(Text(item.airTemperature.toString())),
        DataCell(Text(item.airHumidity.toString())),
        DataCell(Text(item.ecLevel.toString())),
        DataCell(Text(item.waterTemperature.toString())),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
