import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:3000/api';

  Future<List<Order>> fetchMerchantOrders(int merchantId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/merchant/$merchantId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch merchant orders: $e');
    }
  }

  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': newStatus,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
