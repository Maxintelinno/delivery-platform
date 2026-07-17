import 'package:flutter/material.dart';

class Merchant {
  final int id;
  final String name;
  final String address;
  final double rating;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final List<MenuItem> menus;

  // UI-specific properties
  final List<String> tags;
  final String emoji;
  final String distance;
  final String time;
  final String fee;
  final List<Color> colors;

  Merchant({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    required this.menus,
    required this.tags,
    required this.emoji,
    required this.distance,
    required this.time,
    required this.fee,
    required this.colors,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final int id = json['id'] ?? 0;

    // Determine category emoji based on merchant name
    String emoji = '🍔';
    if (name.toLowerCase().contains('cafe') || name.toLowerCase().contains('coffee')) {
      emoji = '☕';
    } else if (name.toLowerCase().contains('mart') || name.toLowerCase().contains('fresh')) {
      emoji = '🍎';
    } else if (name.toLowerCase().contains('courier') || name.toLowerCase().contains('doc')) {
      emoji = '📄';
    } else if (name.toLowerCase().contains('pizza')) {
      emoji = '🍕';
    } else if (name.toLowerCase().contains('salad') || name.toLowerCase().contains('bowl') || name.toLowerCase().contains('healthy')) {
      emoji = '🥗';
    }

    // Determine gradient colors based on ID
    List<Color> colors = const [Color(0xFFFF8A65), Color(0xFFFF5722)];
    switch (id % 5) {
      case 0:
        colors = const [Color(0xFFFF8A65), Color(0xFFFF5722)];
        break;
      case 1:
        colors = const [Color(0xFF81C784), Color(0xFF43A047)];
        break;
      case 2:
        colors = const [Color(0xFF64B5F6), Color(0xFF1E88E5)];
        break;
      case 3:
        colors = const [Color(0xFFFFD54F), Color(0xFFFFB300)];
        break;
      case 4:
        colors = const [Color(0xFF4DB6AC), Color(0xFF009688)];
        break;
    }

    // Determine tags based on merchant name
    List<String> tags = const ['Restaurant', 'Food'];
    if (name.toLowerCase().contains('cafe') || name.toLowerCase().contains('coffee')) {
      tags = const ['Coffee', 'Bakery', 'Desserts'];
    } else if (name.toLowerCase().contains('mart') || name.toLowerCase().contains('fresh')) {
      tags = const ['Groceries', 'Fruits', 'Organic'];
    } else if (name.toLowerCase().contains('courier') || name.toLowerCase().contains('doc')) {
      tags = const ['Documents', 'Express', 'Courier'];
    } else if (name.toLowerCase().contains('pizza')) {
      tags = const ['Pizza', 'Italian', 'Pasta'];
    } else if (name.toLowerCase().contains('salad') || name.toLowerCase().contains('bowl') || name.toLowerCase().contains('healthy')) {
      tags = const ['Salads', 'Healthy', 'Vegetarian'];
    }

    final List<dynamic> menusJson = json['menus'] ?? [];
    final List<MenuItem> menus = menusJson.map((m) => MenuItem.fromJson(m)).toList();

    return Merchant(
      id: id,
      name: name,
      address: json['address'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['isOpen'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      menus: menus,
      tags: tags,
      emoji: emoji,
      distance: '1.5 km',
      time: '15-20 min',
      fee: 'Free',
      colors: colors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'rating': rating,
      'isOpen': isOpen,
      'latitude': latitude,
      'longitude': longitude,
      'menus': menus.map((m) => m.toMap()).toList(),
      'tags': tags,
      'emoji': emoji,
      'distance': distance,
      'time': time,
      'fee': fee,
      'colors': colors,
    };
  }
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String emoji;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.emoji,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    
    String emoji = '🍲';
    if (name.toLowerCase().contains('burger')) {
      emoji = '🍔';
    } else if (name.toLowerCase().contains('fries') || name.toLowerCase().contains('potato')) {
      emoji = '🍟';
    } else if (name.toLowerCase().contains('wrap') || name.toLowerCase().contains('roll')) {
      emoji = '🌯';
    } else if (name.toLowerCase().contains('tea') || name.toLowerCase().contains('matcha') || name.toLowerCase().contains('coffee') || name.toLowerCase().contains('latte') || name.toLowerCase().contains('lemonade') || name.toLowerCase().contains('drink') || name.toLowerCase().contains('beverage')) {
      emoji = '🍹';
    } else if (name.toLowerCase().contains('cake') || name.toLowerCase().contains('souffle') || name.toLowerCase().contains('dessert') || name.toLowerCase().contains('pudding')) {
      emoji = '🧁';
    }

    return MenuItem(
      id: json['id'] ?? 0,
      name: name,
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      emoji: emoji,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': description ?? '', // Map to 'desc' for backward compatibility with UI
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'emoji': emoji,
    };
  }
}
