import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/order_model.dart';
import '../services/api_service.dart';
import 'cart_screen.dart'; // To use TabSwitchNotification
import 'track_rider_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late io.Socket socket;
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _connectSocket();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = ApiService().fetchCustomerOrders(2); // Customer ID 2 for testing
    });
  }

  void _connectSocket() {
    socket = io.io(
      'http://127.0.0.1:3000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.on('orderStatusUpdated', (_) {
      if (mounted) {
        _loadOrders();
      }
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('My Orders'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey[500],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Ongoing'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: FutureBuilder<List<Order>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading orders: ${snapshot.error}'),
                      const SizedBox(height: 12.0),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final orders = snapshot.data ?? [];
            final ongoingOrders = orders.where((o) => o.status == 'PENDING' || o.status == 'ACCEPTED' || o.status == 'PREPARING' || o.status == 'SEARCHING_RIDER' || o.status == 'PICKED_UP' || o.status == 'DELIVERING').toList();
            final historyOrders = orders.where((o) => o.status == 'COMPLETED' || o.status == 'DELIVERED' || o.status == 'CANCELLED' || o.status == 'DECLINED').toList();

            return TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOngoingTab(ongoingOrders, orders.length),
                _buildHistoryTab(historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOngoingTab(List<Order> ongoingOrders, int totalCount) {
    if (ongoingOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Orders found: $totalCount',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16.0),
            Icon(Icons.receipt_long_outlined, size: 48.0, color: Colors.grey[350]),
            const SizedBox(height: 12.0),
            Text(
              'No ongoing orders',
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Total Orders found: $totalCount',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13.0),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            itemCount: ongoingOrders.length,
            itemBuilder: (context, index) {
              final order = ongoingOrders[index];
              return _buildOngoingOrderCard(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOngoingOrderCard(Order order) {
    final theme = Theme.of(context);
    
    // Determine stepper current step based on status
    int currentStep = 0; // default Placed
    String statusTitle = 'Order Placed';
    String statusSubtitle = 'Waiting for merchant confirmation';
    Color statusColor = Colors.orange;

    if (order.status == 'PREPARING') {
      currentStep = 1;
      statusTitle = 'Food is being prepared';
      statusSubtitle = 'Preparing fresh ingredients';
      statusColor = Colors.green;
    } else if (order.status == 'DELIVERING') {
      currentStep = 2;
      statusTitle = 'Rider is En Route';
      statusSubtitle = 'Rider is on the way to you';
      statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        order.merchantEmoji,
                        style: const TextStyle(fontSize: 24.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.merchantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Order ID: ${order.orderRef}',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.headset_mic_outlined, color: theme.primaryColor, size: 22),
                onPressed: () {},
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF3F4F6)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    statusSubtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '15 mins',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const Text(
                    'Est. Arrival',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          _buildProgressStepper(context, currentStep: currentStep),
          const Divider(height: 36, thickness: 1, color: Color(0xFFF3F4F6)),

          const Text(
            'Order Items',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            order.formattedItemsList,
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20.0),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Cancel Order',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackRiderScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Track Rider',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<Order> historyOrders) {
    if (historyOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 48.0, color: Colors.grey[350]),
            const SizedBox(height: 12.0),
            Text(
              'No past orders',
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: historyOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        final order = historyOrders[index];
        return _buildPastOrderCard(order);
      },
    );
  }

  Widget _buildPastOrderCard(Order order) {
    final theme = Theme.of(context);
    final bool isCancelled = order.status == 'CANCELLED';

    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        order.merchantEmoji,
                        style: const TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.merchantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        order.formattedDate,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isCancelled ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  isCancelled ? 'Cancelled' : 'Delivered',
                  style: TextStyle(
                    color: isCancelled ? Colors.red : Colors.green,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF8F9FA)),

          Text(
            order.itemsSummary,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey[600],
              height: 1.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total Paid: ',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13.0),
                  ),
                  Text(
                    '฿${order.totalAmount.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Color(0xFF212121),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reordered items from ${order.merchantName}!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      action: SnackBarAction(
                        label: 'Go to Cart',
                        textColor: Colors.white,
                        onPressed: () {
                          const TabSwitchNotification(2).dispatch(context);
                        },
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Reorder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(BuildContext context, {required int currentStep}) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> steps = [
      {'label': 'Placed', 'icon': Icons.receipt_long},
      {'label': 'Preparing', 'icon': Icons.restaurant},
      {'label': 'Delivery', 'icon': Icons.delivery_dining},
      {'label': 'Arrived', 'icon': Icons.home},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        final isUpcoming = index > currentStep;

        Color stepColor;
        if (isCompleted) {
          stepColor = Colors.green;
        } else if (isCurrent) {
          stepColor = theme.primaryColor;
        } else {
          stepColor = Colors.grey.shade300;
        }

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      color: isCurrent ? stepColor.withOpacity(0.12) : stepColor,
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: stepColor, width: 2.0) : null,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : step['icon'] as IconData,
                      color: isCurrent ? stepColor : Colors.white,
                      size: 16.0,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isCurrent || isCompleted ? FontWeight.bold : FontWeight.w500,
                      color: isUpcoming ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    color: index < currentStep ? Colors.green : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
