class OrderItem {
  final int id;
  final int menuId;
  final int quantity;
  final double price;
  final String menuName;
  final String menuEmoji;

  OrderItem({
    required this.id,
    required this.menuId,
    required this.quantity,
    required this.price,
    required this.menuName,
    required this.menuEmoji,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'] ?? {};
    final String menuName = menu['name'] ?? 'Menu Item';

    // Choose emoji dynamically based on name
    String menuEmoji = '🍲';
    if (menuName.toLowerCase().contains('burger')) {
      menuEmoji = '🍔';
    } else if (menuName.toLowerCase().contains('fries') || menuName.toLowerCase().contains('potato')) {
      menuEmoji = '🍟';
    } else if (menuName.toLowerCase().contains('wrap') || menuName.toLowerCase().contains('roll')) {
      menuEmoji = '🌯';
    } else if (menuName.toLowerCase().contains('tea') || menuName.toLowerCase().contains('matcha') || menuName.toLowerCase().contains('coffee') || menuName.toLowerCase().contains('latte') || menuName.toLowerCase().contains('lemonade') || menuName.toLowerCase().contains('drink') || menuName.toLowerCase().contains('beverage')) {
      menuEmoji = '🍹';
    } else if (menuName.toLowerCase().contains('cake') || menuName.toLowerCase().contains('souffle') || menuName.toLowerCase().contains('dessert') || menuName.toLowerCase().contains('pudding')) {
      menuEmoji = '🧁';
    }

    return OrderItem(
      id: json['id'] ?? 0,
      menuId: json['menuId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      menuName: menuName,
      menuEmoji: menuEmoji,
    );
  }
}

class Order {
  final int id;
  final int customerId;
  final int merchantId;
  final double totalAmount;
  final double deliveryFee;
  final double netAmount;
  final String deliveryAddress;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;
  final List<OrderItem> orderItems;
  final String customerName;
  final String phoneNumber;

  Order({
    required this.id,
    required this.customerId,
    required this.merchantId,
    required this.totalAmount,
    required this.deliveryFee,
    required this.netAmount,
    required this.deliveryAddress,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.orderItems,
    required this.customerName,
    required this.phoneNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['orderItems'] ?? [];
    final List<OrderItem> items = itemsJson.map((x) => OrderItem.fromJson(x)).toList();

    return Order(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      orderItems: items,
      customerName: json['customer'] != null ? (json['customer']['name'] ?? 'Customer') : 'Default Customer',
      phoneNumber: json['customer'] != null ? (json['customer']['phone'] ?? '098-765-4321') : '098-765-4321',
    );
  }

  // Visual/Helper properties
  String get orderRef => '#ORD-$id';
  
  String get time {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String get itemsSummary {
    return orderItems.map((item) => '${item.quantity}x ${item.menuName}').join(', ');
  }
}

class MerchantHistoryResponse {
  final List<Order> orders;
  final double totalRevenue;

  MerchantHistoryResponse({
    required this.orders,
    required this.totalRevenue,
  });
}
