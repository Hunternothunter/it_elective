import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.19:3000/api';

  Future<HydroParameter> getHydroParameters() async {
    final response = await http.get(Uri.parse('$baseUrl/hydro-parameters'));

    if (response.statusCode == 200) {
      return HydroParameter.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load hydro parameters');
    }
  }

  // You can add more methods to fetch components control or user login data if needed
}
