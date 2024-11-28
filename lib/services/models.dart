class HydroParameter {
  final double ph_Level;
  final double tdsLevel;
  final double ecLevel;
  final double airHumidity;
  final double airTemperature;
  final double waterTemperature;
  final String timestamp;

  HydroParameter({
    required this.ph_Level,
    required this.tdsLevel,
    required this.ecLevel,
    required this.airHumidity,
    required this.airTemperature,
    required this.waterTemperature,
    required this.timestamp,
  });

  factory HydroParameter.fromJson(Map<String, dynamic> json) {
    return HydroParameter(
      tdsLevel: double.tryParse(json['tds_level'].toString()) ?? 0.0,
      ph_Level: double.tryParse(json['pH_level'].toString()) ?? 0.0,
      ecLevel: double.tryParse(json['ec_level'].toString()) ?? 0.0,
      waterTemperature:
          double.tryParse(json['water_temperature'].toString()) ?? 0.0,
      airTemperature:
          double.tryParse(json['air_temperature'].toString()) ?? 0.0,
      airHumidity: double.tryParse(json['air_humidity'].toString()) ?? 0.0,
      timestamp: json['timestamp'] ?? 'Unknown',
    );
  }
}

class ComponentControl {
  final String componentName;
  final int dispenseAmount;

  ComponentControl({
    required this.componentName,
    required this.dispenseAmount,
  });

  factory ComponentControl.fromJson(Map<String, dynamic> json) {
    return ComponentControl(
      componentName: json['component_name'],
      dispenseAmount: json['dispense_amount'],
    );
  }
}

class HydroData {
  final int id;
  final String hydroUuid;
  final double phLevel;
  final double tdsLevel;
  final double ecLevel;
  final double airHumidity;
  final double airTemperature;
  final double waterTemperature;
  final String timestamp;

  HydroData({
    required this.id,
    required this.hydroUuid,
    required this.phLevel,
    required this.tdsLevel,
    required this.ecLevel,
    required this.airHumidity,
    required this.airTemperature,
    required this.waterTemperature,
    required this.timestamp,
  });

  // Factory method to create an instance of HydroData from a JSON object
  factory HydroData.fromJson(Map<String, dynamic> json) {
    return HydroData(
      id: json['id'] ?? 0, // Fallback to 0 if the value is null
      hydroUuid: json['hydro_uuid'] ?? '', // Fallback to empty string if null
      phLevel: json['pH_level'] != null
          ? double.tryParse(json['pH_level'].toString()) ?? 0.0
          : 0.0,
      tdsLevel: json['tds_level'] != null
          ? double.tryParse(json['tds_level'].toString()) ?? 0.0
          : 0.0,
      ecLevel: json['ec_level'] != null
          ? double.tryParse(json['ec_level'].toString()) ?? 0.0
          : 0.0,
      airHumidity: json['air_humidity'] != null
          ? double.tryParse(json['air_humidity'].toString()) ?? 0.0
          : 0.0,
      airTemperature: json['air_temperature'] != null
          ? double.tryParse(json['air_temperature'].toString()) ?? 0.0
          : 0.0,
      waterTemperature: json['water_temperature'] != null
          ? double.tryParse(json['water_temperature'].toString()) ?? 0.0
          : 0.0,
      timestamp: json['timestamp'] ??
          '', // Fallback to empty string if timestamp is null
    );
  }
}

class Notification {
  String message;
  bool isRead;
  String created_at;
  String type;

  Notification({
    required this.message,
    required this.isRead,
    required this.created_at,
    required this.type,
  });

  void markAsRead() {
    isRead = true;
  }

  // Factory constructor to handle null fields safely
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      message: json['message'] ?? 'No message', // Provide default values
      isRead: json['is_read'] ==
          1, // assuming 1 means read, handle other cases as needed
      created_at: json['created_at'] ??
          'Unknown time', // Provide default value for null
      type: json['type'] ?? 'Unknown', // Handle type being null
    );
  }
}
