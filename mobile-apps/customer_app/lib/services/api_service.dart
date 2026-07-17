import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/merchant_model.dart';
import '../models/order_model.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';

  Future<List<Merchant>> fetchMerchants() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/merchants'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Merchant.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load merchants: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch merchants: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMerchantDetails(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/merchants/$id'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final merchant = Merchant.fromJson(data);
        return merchant.toMap();
      } else {
        throw Exception('Failed to load merchant details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch merchant details: $e');
    }
  }

  Future<bool> createOrder({
    required int merchantId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    required String deliveryAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'customerId': 2,
          'merchantId': merchantId,
          'items': items,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'deliveryAddress': deliveryAddress,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  Future<List<Order>> fetchCustomerOrders(int customerId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/orders/customer/$customerId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Order.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load customer orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer orders: $e');
    }
  }
}
