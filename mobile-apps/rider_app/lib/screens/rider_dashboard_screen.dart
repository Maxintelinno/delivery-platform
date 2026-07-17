import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/order_model.dart';
import '../services/api_service.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _connectSocket();
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
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  // Theme Constants suitable for outdoor visibility
  static const Color _bgColor = Color(0xFF0C0E14);        // Extra dark backdrop
  static const Color _cardColor = Color(0xFF161A26);      // Dark slate containers
  static const Color _accentNeon = Color(0xFF39FF14);     // High visibility neon green
  static const Color _accentOrange = Color(0xFFFF9F0A);   // Active warning orange
  static const Color _textWhite = Color(0xFFF2F5FA);      // High-contrast white text
  static const Color _textMuted = Color(0xFF8E9AA8);      // Muted slate text
  static const Color _borderColor = Color(0xFF242C3F);    // Container border

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10.0,
              height: 10.0,
              decoration: const BoxDecoration(
                color: _accentNeon,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _accentNeon,
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            const Text(
              'RIDER PORTAL',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: _textWhite,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
        backgroundColor: _bgColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: _textWhite),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: _textWhite),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _accentNeon,
          labelColor: _accentNeon,
          unselectedLabelColor: _textMuted,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: _borderColor,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, letterSpacing: 0.8),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.0),
          tabs: const [
            Tab(
              icon: Icon(Icons.explore_outlined),
              text: 'AVAILABLE JOBS',
            ),
            Tab(
              icon: Icon(Icons.navigation_outlined),
              text: 'ACTIVE TASK',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildAvailableJobsTab(),
          _buildActiveTaskTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableJobsTab() {
    return FutureBuilder<List<Order>>(
      future: ApiService().fetchAvailableJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _accentNeon));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _borderColor),
                    onPressed: () => setState(() {}),
                    child: const Text('RETRY', style: TextStyle(color: _textWhite)),
                  ),
                ],
              ),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyStateRadar();
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildAvailableJobCard(order);
          },
        );
      },
    );
  }

  Widget _buildEmptyStateRadar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160.0,
                height: 160.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentNeon.withOpacity(0.15), width: 2.0),
                ),
              ),
              Container(
                width: 110.0,
                height: 110.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentNeon.withOpacity(0.3), width: 1.5),
                ),
              ),
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: _accentNeon.withOpacity(0.08),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accentNeon.withOpacity(0.2),
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sensors,
                  color: _accentNeon,
                  size: 28.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          const Text(
            'Looking for nearby orders...',
            style: TextStyle(
              color: _textWhite,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Your GPS status is active. Keeping you visible to local merchants.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textMuted,
              fontSize: 13.0,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableJobCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER ID: ${order.orderRef}',
                style: const TextStyle(
                  color: _textWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 15.0,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _accentNeon.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  '${order.totalItemsCount} ITEMS',
                  style: const TextStyle(
                    color: _accentNeon,
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Merchant details
          Row(
            children: [
              const Icon(Icons.storefront, color: _accentNeon, size: 18.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  order.merchantName,
                  style: const TextStyle(
                    color: _textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Address details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: _textMuted, size: 18.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13.0,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Items summary text
          Text(
            order.itemsSummary,
            style: const TextStyle(
              color: _textMuted,
              fontSize: 12.0,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20.0),

          // Accept job action button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              elevation: 0,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Accepted order ${order.orderRef}!'),
                  backgroundColor: _cardColor,
                ),
              );
            },
            child: const Text(
              'ACCEPT JOB',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.0,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTaskTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Alert Badge Info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: _accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: _accentOrange.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: _accentOrange, size: 20.0),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'No active delivery task assigned.',
                    style: TextStyle(
                      color: _accentOrange,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Mock Task Placeholder Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _textMuted.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: const Text(
                        'IDLE STATE',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Text(
                      '-- mins',
                      style: TextStyle(
                        color: _textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Accept a job from the "Available Jobs" list to start tracking items and routing deliveries.',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 13.0,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                const Divider(color: _borderColor, height: 1.0),
                const SizedBox(height: 16.0),
                
                // Stepper placeholder indicators
                _buildTaskStep(
                  icon: Icons.storefront,
                  title: 'Step 1: Pick Up',
                  subtitle: 'Collect order packages from Merchant Hub.',
                  isActive: false,
                ),
                const SizedBox(height: 16.0),
                _buildTaskStep(
                  icon: Icons.person_pin_circle_outlined,
                  title: 'Step 2: Drop Off',
                  subtitle: 'Deliver directly to customer residence address.',
                  isActive: false,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isActive,
    bool isLast = false,
  }) {
    final Color stepColor = isActive ? _accentNeon : _textMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: stepColor.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: stepColor, width: 2.0),
              ),
              child: Icon(icon, color: stepColor, size: 16.0),
            ),
            if (!isLast)
              Container(
                width: 2.0,
                height: 30.0,
                color: _borderColor,
              ),
          ],
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textWhite,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12.0,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
