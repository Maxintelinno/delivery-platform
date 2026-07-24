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

  Future<void> acceptJob(int orderId, int riderId) async {
    try {
      print('Sending PUT request to accept job...');
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/accept'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'riderId': riderId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to accept job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error accepting job: $e');
    }
  }

  Future<Order?> fetchActiveTask(int riderId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/rider/$riderId/active'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Order.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load active task: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch active task: $e');
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': newStatus,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating status: $e');
    }
  }

  Future<RiderHistoryResponse> fetchRiderHistory(int riderId, String date) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/rider/$riderId/history?date=$date'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> ordersList = data['orders'] ?? [];
        final List<Order> orders = ordersList.map((item) => Order.fromJson(item)).toList();
        final double totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        return RiderHistoryResponse(orders: orders, totalAmount: totalAmount);
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch history: $e');
    }
  }
}
