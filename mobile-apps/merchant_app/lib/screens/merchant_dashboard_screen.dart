import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/order_model.dart'; 
import '../services/api_service.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  int? _selectedOrderId;
  List<Order>? _orders;
  late Future<List<Order>> _ordersFuture;
  late io.Socket socket;  
  Future<List<Order>>? _preparingOrdersFuture;
  DateTime _historySelectedDate = DateTime.now();

  // Premium Palette
  static const Color _bgColor = Color(0xFF0F1016);        // Deep charcoal/navy
  static const Color _cardColor = Color(0xFF1D1F2D);      // Lighter slate for cards
  static const Color _accentGold = Color(0xFFDFB76C);     // Soft gold
  static const Color _textWhite = Color(0xFFF7FAFC);      // Off-white text
  static const Color _textGrey = Color(0xFF94A3B8);       // Muted slate text
  static const Color _dividerColor = Color(0xFF26293B);   // Soft border/divider slate
  static const Color _coralRed = Color(0xFFF87171);       // Elegant coral red

  

@override
void initState() {
  super.initState();
  _connectSocket();
  _loadOrders(); // เรียกฟังก์ชันเดียวพอครับ
}

void _loadOrders() {
  setState(() {
    _ordersFuture = ApiService().fetchMerchantOrders(1);
  });
  
  // นำผลลัพธ์มาจัดการหลังจากโหลดเสร็จ
  _ordersFuture?.then((value) {
    if (mounted) {
      setState(() {
        _orders = value;
        if (_orders != null && _orders!.isNotEmpty) {
          _selectedOrderId = _orders!.first.id;
        }
      });
    }
  });
}

void _connectSocket() {
  socket = io.io(
    'http://127.0.0.1:3000',
    io.OptionBuilder().setTransports(['websocket']).build(),
  );
  socket.connect();

  void handleOrderEvent(data) {
    if (mounted) {
      _loadOrders();
    }
  }
  
  socket.on('newOrder', handleOrderEvent);
  socket.on('orderCreated', handleOrderEvent);
  socket.on('orderStatusUpdated', handleOrderEvent);
}

  void _acceptOrder(int id) {
    // Optimistic UI update: instantly move to Preparing status locally
    setState(() {
      if (_orders != null) {
        final index = _orders!.indexWhere((o) => o.id == id);
        if (index != -1) {
          final order = _orders![index];
          _orders![index] = Order(
            id: order.id,
            customerId: order.customerId,
            merchantId: order.merchantId,
            totalAmount: order.totalAmount,
            deliveryFee: order.deliveryFee,
            netAmount: order.netAmount,
            deliveryAddress: order.deliveryAddress,
            status: 'PREPARING',
            paymentMethod: order.paymentMethod,
            createdAt: order.createdAt,
            orderItems: order.orderItems,
            customerName: order.customerName,
            phoneNumber: order.phoneNumber,
          );
        }
      }
    });

    ApiService().updateOrderStatus(id, 'PREPARING').then((success) {
      if (!success) {
        // Rollback on failure
        _loadOrders();
        _showSnackBar('Failed to accept order. Please try again.', Colors.red);
      } else {
        _showSnackBar('Order accepted successfully!', Colors.green);
      }
    });
  }

  void _declineOrder(int id) {
    String ref = '';
    // Optimistic UI update: instantly remove from list locally
    setState(() {
      if (_orders != null) {
        final index = _orders!.indexWhere((o) => o.id == id);
        if (index != -1) {
          ref = _orders![index].orderRef;
          _orders!.removeAt(index);
          _selectedOrderId = _orders!.isNotEmpty ? _orders!.first.id : null;
        }
      }
    });

    ApiService().updateOrderStatus(id, 'DECLINED').then((success) {
      if (!success) {
        // Rollback on failure
        _loadOrders();
        _showSnackBar('Failed to decline order. Please try again.', Colors.red);
      } else {
        _showSnackBar('Order $ref declined.', _coralRed);
      }
    });
  }



  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _orders == null) {
          return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              elevation: 0,
              title: const Text(
                'Merchant Center',
                style: TextStyle(fontWeight: FontWeight.bold, color: _textWhite),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_accentGold)),
            ),
          );
        }

        if (snapshot.hasError && _orders == null) {
          return Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              elevation: 0,
              title: const Text(
                'Merchant Center',
                style: TextStyle(fontWeight: FontWeight.bold, color: _textWhite),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: _textWhite),
                    ),
                    const SizedBox(height: 12.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentGold,
                        foregroundColor: _bgColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      ),
                      onPressed: _loadOrders,
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final ordersList = _orders ?? [];
        final incomingCount = ordersList.where((o) => o.status == 'PENDING').length;
        final preparingCount = ordersList.where((o) => o.status == 'PREPARING' || o.status == 'READY' || o.status == 'DELIVERING').length;
        final completedCount = ordersList.where((o) => o.status == 'DELIVERED' || o.status == 'COMPLETED').length;

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            backgroundColor: _bgColor,
            appBar: AppBar(
              backgroundColor: _bgColor,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              title: const Row(
                children: [
                  Text(
                    'Chef\'s Desk',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.0,
                      letterSpacing: 0.5,
                      color: _textWhite,
                    ),
                  ),
                  Text(
                    ' .',
                    style: TextStyle(
                      color: _accentGold,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: _accentGold),
                  onPressed: _loadOrders,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16.0, left: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: _dividerColor),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 10.0,
                        backgroundColor: _accentGold,
                        child: Text(
                          'M',
                          style: TextStyle(fontSize: 10.0, color: _bgColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'Station 1',
                        style: TextStyle(fontSize: 12.0, color: _textWhite, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Dashboard Header Quick Stats Section
                  _buildStatsHeader(incomingCount, preparingCount, completedCount),

                  // 2. Tab Bar Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: _dividerColor),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: _accentGold.withOpacity(0.5)),
                      ),
                      labelColor: _accentGold,
                      unselectedLabelColor: _textGrey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.0),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox_outlined, size: 16.0),
                              const SizedBox(width: 6.0),
                              Text('Incoming ($incomingCount)'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.soup_kitchen_outlined, size: 16.0),
                              const SizedBox(width: 6.0),
                              Text('Preparing ($preparingCount)'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16.0),
                              const SizedBox(width: 6.0),
                              Text('Completed ($completedCount)'),
                            ],
                          ),
                        ),
                        const Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_outlined, size: 16.0),
                              SizedBox(width: 6.0),
                              Text('HISTORY'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Responsive body content
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;
                        if (isTablet) {
                          return _buildTabletLayout(ordersList);
                        } else {
                          return _buildMobileLayout(ordersList);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dashboard stats header
  Widget _buildStatsHeader(int incoming, int preparing, int completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good Evening, Merchant',
            style: TextStyle(
              color: _textWhite,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            'Here is today\'s real-time POS overview.',
            style: TextStyle(
              color: _textGrey,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  'Incoming',
                  incoming.toString(),
                  Colors.amber.withOpacity(0.1),
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildMiniStatCard(
                  'Preparing',
                  preparing.toString(),
                  Colors.blue.withOpacity(0.1),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: _buildMiniStatCard(
                  'Completed',
                  completed.toString(),
                  _accentGold.withOpacity(0.1),
                  _accentGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String count, Color glowBg, Color glowColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: glowColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.5),
                  blurRadius: 6.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.0, color: _textGrey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2.0),
                Text(
                  count,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.0, color: _textWhite, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TABLET LAYOUT (Split Master-Detail View)
  Widget _buildTabletLayout(List<Order> ordersList) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Panel: Orders Master list (Flex: 1)
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: _dividerColor, width: 1.0),
              ),
            ),
            child: TabBarView(
              children: [
                _buildOrdersList(ordersList, 'PENDING', isCompact: true),
                _buildOrdersList(ordersList, 'PREPARING', isCompact: true),
                _buildOrdersList(ordersList, 'DELIVERED', isCompact: true),
                _buildHistoryTab(),
              ],
            ),
          ),
        ),
        // Right Panel: Order Details (Flex: 2)
        Expanded(
          flex: 2,
          child: _buildDetailsPanel(ordersList),
        ),
      ],
    );
  }

  // MOBILE LAYOUT (Full Screen Tabs)
  Widget _buildMobileLayout(List<Order> ordersList) {
    return TabBarView(
      children: [
        _buildOrdersList(ordersList, 'PENDING', isCompact: false),
        _buildOrdersList(ordersList, 'PREPARING', isCompact: false),
        _buildOrdersList(ordersList, 'DELIVERED', isCompact: false),
        _buildHistoryTab(),
      ],
    );
  }

  // Orders list filtered by status
  Widget _buildOrdersList(List<Order> ordersList, String status, {required bool isCompact}) {
    final filteredOrders = ordersList.where((o) {
      if (status == 'PENDING') {
        return o.status == 'PENDING';
      } else if (status == 'PREPARING') {
        return o.status == 'PREPARING' || o.status == 'READY' || o.status == 'DELIVERING';
      } else {
        return o.status == 'DELIVERED' || o.status == 'COMPLETED';
      }
    }).toList();

    if (filteredOrders.isEmpty) {
      String displayStatus = status == 'PENDING'
          ? 'incoming'
          : status == 'PREPARING'
              ? 'preparing'
              : 'completed';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 40.0, color: _dividerColor),
            const SizedBox(height: 12.0),
            Text(
              'No $displayStatus orders yet',
              style: const TextStyle(
                color: _textGrey,
                fontSize: 13.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        if (isCompact) {
          return _buildCompactOrderCard(order);
        } else {
          return _buildFullOrderCard(order);
        }
      },
    );
  }

  // Compact card (used in Master list on Tablet view)
  Widget _buildCompactOrderCard(Order order) {
    final bool isSelected = _selectedOrderId == order.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? _accentGold.withOpacity(0.08) : _cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isSelected ? _accentGold : _dividerColor,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          setState(() {
            _selectedOrderId = order.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderRef,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: isSelected ? _accentGold : _textWhite,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    order.time,
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '฿${order.totalAmount.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.0,
                  color: _accentGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Full order card (used in Mobile view directly)
  Widget _buildFullOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: _dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      order.orderRef,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: _textWhite,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _bgColor,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: _dividerColor),
                      ),
                      child: Text(
                        order.time,
                        style: const TextStyle(
                          color: _accentGold,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '฿${order.totalAmount.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16.5,
                    color: _accentGold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24.0, color: _dividerColor),
            const Text(
              'ITEMS ORDERED',
              style: TextStyle(
                color: _textGrey,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              order.itemsSummary,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: _textWhite,
                height: 1.4,
              ),
            ),
            if (order.status == 'PENDING') ...[
              const Divider(height: 28.0, color: _dividerColor),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _coralRed,
                        side: const BorderSide(color: _coralRed, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      onPressed: () => _declineOrder(order.id),
                      child: const Text(
                        'Decline',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC5A059), Color(0xFFE5C180)],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: _bgColor,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                        ),
                        onPressed: () => _acceptOrder(order.id),
                        child: const Text(
                          'Accept Order',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING') ...[
              const Divider(height: 28.0, color: _dividerColor),
              SizedBox(
                width: double.infinity,
                child: buildActionButton(order),
              ),
            ] else ...[
              const Divider(height: 28.0, color: _dividerColor),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: _dividerColor),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: _accentGold, size: 16.0),
                      SizedBox(width: 6.0),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _accentGold,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Detailed recipe panel (Master-Detail layout right panel)
  Widget _buildDetailsPanel(List<Order> ordersList) {
    if (_selectedOrderId == null) {
      return const Center(
        child: Text(
          'Select an order to view details',
          style: TextStyle(color: _textGrey),
        ),
      );
    }

    final orderIndex = ordersList.indexWhere((o) => o.id == _selectedOrderId);
    if (orderIndex == -1) {
      return const Center(
        child: Text(
          'Order not found',
          style: TextStyle(color: _textGrey),
        ),
      );
    }

    final order = ordersList[orderIndex];
    final itemsList = order.orderItems;

    return Container(
      color: _bgColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: _dividerColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderRef,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: _textWhite,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Time: ${order.time}',
                      style: const TextStyle(
                        color: _textGrey,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: order.status == 'PENDING'
                        ? Colors.amber.withOpacity(0.08)
                        : order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING'
                            ? Colors.blue.withOpacity(0.08)
                            : _accentGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: order.status == 'PENDING'
                          ? Colors.amber
                          : order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING'
                              ? Colors.blue
                              : _accentGold,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: order.status == 'PENDING'
                          ? Colors.amber
                          : order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING'
                              ? Colors.blue
                              : _accentGold,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Items List Section
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ORDER RECIPE DETAILS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.0,
                      letterSpacing: 1.0,
                      color: _textGrey,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: _dividerColor),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemsList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1.0, color: _dividerColor),
                      itemBuilder: (context, index) {
                        final item = itemsList[index];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.quantity}x   ${item.menuName}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: _textWhite,
                                ),
                              ),
                              Text(
                                '฿${item.price.toInt()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: _accentGold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // Customer Details Section
                  const Text(
                    'CUSTOMER & PAYMENT RECEIPT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.0,
                      letterSpacing: 1.0,
                      color: _textGrey,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: _dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Customer Name', order.customerName),
                        const SizedBox(height: 12.0),
                        _buildDetailRow('Delivery Address', order.deliveryAddress),
                        const SizedBox(height: 12.0),
                        _buildDetailRow('Contact Phone', order.phoneNumber),
                        const SizedBox(height: 12.0),
                        _buildDetailRow('Payment Option', order.paymentMethod),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Footer Action Buttons
          if (order.status == 'PENDING')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _coralRed,
                      side: const BorderSide(color: _coralRed, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                    ),
                    onPressed: () => _declineOrder(order.id),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC5A059), Color(0xFFE5C180)],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: _bgColor,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                      ),
                      onPressed: () => _acceptOrder(order.id),
                      child: const Text(
                        'Accept Order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING')
            buildActionButton(order)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: _dividerColor),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: _accentGold, size: 18.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _accentGold,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.0,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: _textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: _textWhite,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickHistoryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _historySelectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accentGold,
              onPrimary: _bgColor,
              surface: _cardColor,
              onSurface: _textWhite,
            ),
            dialogBackgroundColor: _bgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _historySelectedDate) {
      setState(() {
        _historySelectedDate = picked;
      });
    }
  }

  Widget _buildHistoryTab() {
    final String dateParam =
        "${_historySelectedDate.year}-${_historySelectedDate.month.toString().padLeft(2, '0')}-${_historySelectedDate.day.toString().padLeft(2, '0')}";

    return FutureBuilder<MerchantHistoryResponse>(
      future: ApiService().fetchMerchantHistory(1, date: dateParam),
      builder: (context, snapshot) {
        double totalRevenue = 0.0;
        List<Order> orders = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasData) {
          totalRevenue = snapshot.data!.totalRevenue;
          orders = snapshot.data!.orders;
        }

        return Column(
          children: [
            // 1. Summary Header Card (Total Revenue & Date Picker)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: _dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.monetization_on_outlined, color: _accentGold, size: 20.0),
                            SizedBox(width: 8.0),
                            Text(
                              'TOTAL REVENUE',
                              style: TextStyle(
                                color: _textGrey,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _pickHistoryDate,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: _bgColor,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: _accentGold.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, color: _accentGold, size: 14.0),
                                const SizedBox(width: 6.0),
                                Text(
                                  dateParam,
                                  style: const TextStyle(
                                    color: _textWhite,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      '฿${totalRevenue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.w900,
                        color: _accentGold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Orders list
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _accentGold),
                    )
                  : snapshot.hasError
                      ? Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_outlined, size: 48.0, color: _dividerColor),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    'No completed sales on $dateParam',
                                    style: const TextStyle(
                                      color: _textGrey,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: _cardColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(color: _dividerColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            order.orderRef,
                                            style: const TextStyle(
                                              color: _textWhite,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8.0),
                                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                                            ),
                                            child: const Text(
                                              'COMPLETED',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, color: _textGrey, size: 16.0),
                                          const SizedBox(width: 6.0),
                                          Text(
                                            order.customerName,
                                            style: const TextStyle(
                                              color: _textWhite,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        order.itemsSummary,
                                        style: const TextStyle(
                                          color: _textGrey,
                                          fontSize: 12.0,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Divider(height: 20.0, color: _dividerColor),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Order Amount',
                                            style: TextStyle(
                                              color: _textGrey,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          Text(
                                            '฿${order.totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: _accentGold,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget buildActionButton(Order order) {
    if (order.status == 'PREPARING') {
      return ElevatedButton(
        onPressed: () async {
          await ApiService().updateOrderStatus(order.id, 'READY');
          setState(() {}); // Refresh state
        },
        child: const Text('Mark as Food Ready'),
      );
    } else if (order.status == 'READY') {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        onPressed: null,
        child: const Text('Waiting for Rider...'),
      );
    } else if (order.status == 'DELIVERING') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Rider is delivering...',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
