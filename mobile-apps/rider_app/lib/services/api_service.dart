import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:3000/api';

  Future<List<Order>> fetchAvailableJobs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/available'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load available jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch available jobs: $e');
    }
  }
}
