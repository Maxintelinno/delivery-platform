class OrderItem {
  final int id;
  final int menuId;
  final int quantity;
  final double price;
  final String menuName;

  OrderItem({
    required this.id,
    required this.menuId,
    required this.quantity,
    required this.price,
    required this.menuName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'] ?? {};
    return OrderItem(
      id: json['id'] ?? 0,
      menuId: json['menuId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      menuName: menu['name'] ?? 'Item',
    );
  }
}

class Order {
  final int id;
  final int customerId;
  final int merchantId;
  final String merchantName;
  final String merchantEmoji;
  final double totalAmount;
  final double deliveryFee;
  final double netAmount;
  final String deliveryAddress;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.customerId,
    required this.merchantId,
    required this.merchantName,
    required this.merchantEmoji,
    required this.totalAmount,
    required this.deliveryFee,
    required this.netAmount,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['orderItems'] ?? [];
    final List<OrderItem> items = itemsJson.map((x) => OrderItem.fromJson(x)).toList();
    final merchant = json['merchant'] ?? {};
    final String merchantName = merchant['name'] ?? 'Cafe Bistro';

    // Choose emoji dynamically based on name
    String merchantEmoji = '🍲';
    if (merchantName.toLowerCase().contains('pizza')) {
      merchantEmoji = '🍕';
    } else if (merchantName.toLowerCase().contains('noodle') || merchantName.toLowerCase().contains('ramen')) {
      merchantEmoji = '🍜';
    } else if (merchantName.toLowerCase().contains('bistro') || merchantName.toLowerCase().contains('cafe')) {
      merchantEmoji = '☕';
    } else if (merchantName.toLowerCase().contains('burger')) {
      merchantEmoji = '🍔';
    } else if (merchantName.toLowerCase().contains('market') || merchantName.toLowerCase().contains('fresh')) {
      merchantEmoji = '🥬';
    }

    return Order(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      merchantName: merchantName,
      merchantEmoji: merchantEmoji,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      orderItems: items,
    );
  }

  String get orderRef => '#ORD-$id';

  String get itemsSummary {
    return orderItems.map((item) => '${item.quantity}x ${item.menuName}').join(', ');
  }

  String get formattedItemsList {
    return orderItems.map((item) => '${item.quantity}x ${item.menuName}').join('\n');
  }

  String get formattedDate {
    // Basic date formatting: "14 Jul 2026 • 19:30"
    final day = createdAt.day.toString().padLeft(2, '0');
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[createdAt.month - 1];
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$minute';
  }
}
