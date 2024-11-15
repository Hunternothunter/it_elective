class HydroParameter {
  final double pHLevel;
  final double tdsLevel;
  final double ecLevel;
  final double waterTemperature;
  final double airTemperature;
  final double airHumidity;
  final String timestamp;

  HydroParameter({
    required this.pHLevel,
    required this.tdsLevel,
    required this.ecLevel,
    required this.waterTemperature,
    required this.airTemperature,
    required this.airHumidity,
    required this.timestamp,
  });

  factory HydroParameter.fromJson(Map<String, dynamic> json) {
    return HydroParameter(
      pHLevel: double.tryParse(json['pH_level'].toString()) ?? 0.0,  // Convert String to Double
      tdsLevel: double.tryParse(json['tds_level'].toString()) ?? 0.0,  // Convert String to Double
      ecLevel: double.tryParse(json['ec_level'].toString()) ?? 0.0,  // Convert String to Double
      waterTemperature: double.tryParse(json['water_temperature'].toString()) ?? 0.0,  // Convert String to Double
      airTemperature: double.tryParse(json['air_temperature'].toString()) ?? 0.0,  // Convert String to Double
      airHumidity: double.tryParse(json['air_humidity'].toString()) ?? 0.0,  // Convert String to Double
      timestamp: json['timestamp'] ?? '',  // Assuming timestamp is a string
    );
  }
}
