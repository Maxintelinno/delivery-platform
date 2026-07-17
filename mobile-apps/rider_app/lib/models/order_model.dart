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
  final double totalAmount;
  final String deliveryAddress;
  final String status;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.customerId,
    required this.merchantId,
    required this.merchantName,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['orderItems'] ?? [];
    final List<OrderItem> items = itemsJson.map((x) => OrderItem.fromJson(x)).toList();
    final merchant = json['merchant'] ?? {};
    return Order(
      id: json['id'] ?? 0,
      customerId: json['customerId'] ?? 0,
      merchantId: json['merchantId'] ?? 0,
      merchantName: merchant['name'] ?? 'Cafe Bistro',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] ?? '',
      status: json['status'] ?? 'PENDING',
      orderItems: items,
    );
  }

  String get orderRef => '#ORD-$id';

  int get totalItemsCount {
    return orderItems.fold(0, (sum, item) => sum + item.quantity);
  }

  String get itemsSummary {
    return orderItems.map((item) => '${item.quantity}x ${item.menuName}').join(', ');
  }
}
