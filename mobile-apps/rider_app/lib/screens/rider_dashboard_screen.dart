import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  Future<Order?>? _activeTaskFuture;
  DateTime _selectedDate = DateTime.now();

@override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _activeTaskFuture = ApiService().fetchActiveTask(1);
    _connectSocket();

    // เพิ่มตรงนี้เข้าไปครับ:
    // สมมติว่า socket ของคุณถูกประกาศไว้ในคลาสหรือถูกเรียกผ่านตัวแปร global
    // ให้มั่นใจว่าคุณเข้าถึงตัวแปร socket ได้นะครับ
    socket.on('orderStatusUpdated', (data) {
      print('Order status updated: $data');
      setState(() {
        _activeTaskFuture = ApiService().fetchActiveTask(1);
      });
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
        setState(() {
          _activeTaskFuture = ApiService().fetchActiveTask(1);
        });
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
            Tab(
              icon: Icon(Icons.history_outlined),
              text: 'HISTORY',
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
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableJobsTab() {
    return FutureBuilder<List<Order>>(
      future: ApiService().fetchAvailableJobs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildEmptyStateRadar();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return _buildEmptyStateRadar();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Found ${orders.length} jobs ready for pickup',
                style: const TextStyle(
                  color: _accentNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildAvailableJobCard(order);
                },
              ),
            ),
          ],
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              elevation: 0,
            ),
            onPressed: () async {
              try {
                await ApiService().acceptJob(order.id, 1);
                setState(() {
                  _activeTaskFuture = ApiService().fetchActiveTask(1);
                });
                _tabController.animateTo(1); // ย้ายไปหน้า Active Task
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text(
              'ACCEPT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.0, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTaskTab() {
    return FutureBuilder<Order?>(
      future: _activeTaskFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _accentNeon),
          );
        }

        final order = snapshot.data;
        if (order == null) {
          return _buildEmptyActiveTaskState();
        }

        return _buildActiveTaskDetails(order);
      },
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _accentNeon,
              onPrimary: Colors.black,
              surface: _cardColor,
              onSurface: _textWhite,
            ),
            dialogBackgroundColor: _bgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildHistoryTab() {
    final String dateParam =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    return FutureBuilder<RiderHistoryResponse>(
      future: ApiService().fetchRiderHistory(1, dateParam),
      builder: (context, snapshot) {
        double totalAmount = 0.0;
        List<Order> orders = [];
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (snapshot.hasData) {
          totalAmount = snapshot.data!.totalAmount;
          orders = snapshot.data!.orders;
        }

        return Column(
          children: [
            // 1. Date Picker & Total Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Earnings - $dateParam',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, color: _accentNeon),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '฿${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _accentNeon,
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
                      child: CircularProgressIndicator(color: _accentNeon),
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
                                  Icon(Icons.history, color: _textMuted.withOpacity(0.4), size: 64.0),
                                  const SizedBox(height: 16.0),
                                  const Text(
                                    'No completed orders on this day',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
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
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  padding: const EdgeInsets.all(16.0),
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
                                              color: Colors.green.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.check_circle_outline, color: Colors.green, size: 12.0),
                                                SizedBox(width: 4.0),
                                                Text(
                                                  'COMPLETED',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
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
                                      const Divider(height: 24.0, color: _borderColor),

                                      // Summary & Total
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              order.itemsSummary,
                                              style: const TextStyle(
                                                color: _textMuted,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '฿${order.totalAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: _accentNeon,
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

  Widget _buildEmptyActiveTaskState() {
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

  GoogleMapController? _mapController;

  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#181818"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#3c3c3c"}]
    },
    {
      "featureType": "transit",
      "elementType": "geometry",
      "stylers": [{"color": "#2f2f2f"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  void _onMapCreated(GoogleMapController controller, Order order) {
    _mapController = controller;
    _fitCameraBounds(order);
  }

  void _fitCameraBounds(Order order) {
    if (_mapController == null) return;

    final pickup = LatLng(order.merchantLatitude, order.merchantLongitude);
    final delivery = LatLng(order.deliveryLatitude, order.deliveryLongitude);

    final southWest = LatLng(
      pickup.latitude < delivery.latitude ? pickup.latitude : delivery.latitude,
      pickup.longitude < delivery.longitude ? pickup.longitude : delivery.longitude,
    );
    final northEast = LatLng(
      pickup.latitude > delivery.latitude ? pickup.latitude : delivery.latitude,
      pickup.longitude > delivery.longitude ? pickup.longitude : delivery.longitude,
    );

    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  Widget _buildGoogleMap(Order order) {
    final LatLng pickupPos = LatLng(order.merchantLatitude, order.merchantLongitude);
    final LatLng deliveryPos = LatLng(order.deliveryLatitude, order.deliveryLongitude);

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupPos,
        infoWindow: InfoWindow(title: 'Pickup: ${order.merchantName}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('delivery'),
        position: deliveryPos,
        infoWindow: InfoWindow(title: 'Deliver: ${order.deliveryAddress}'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [pickupPos, deliveryPos],
        color: _accentNeon,
        width: 4,
      ),
    };

    return GoogleMap(
      style: _darkMapStyle,
      initialCameraPosition: CameraPosition(
        target: pickupPos,
        zoom: 14,
      ),
      onMapCreated: (controller) => _onMapCreated(controller, order),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      markers: markers,
      polylines: polylines,
    );
  }

  Widget _buildActiveTaskDetails(Order order) {
    final bool isPreparing = order.status == 'PREPARING';
    return Stack(
      children: [
        // Background (Google Maps Integration)
        _buildGoogleMap(order),

        // Foreground (Floating Details Sheet)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: _borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 16.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE TASK: ${order.orderRef}',
                        style: const TextStyle(
                          color: _textWhite,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isPreparing
                              ? _accentOrange.withOpacity(0.12)
                              : _accentNeon.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: isPreparing ? _accentOrange : _accentNeon,
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Pickup info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.storefront, color: _accentNeon, size: 20.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PICKUP FROM',
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              order.merchantName,
                              style: const TextStyle(
                                color: _textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Dropoff info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: _accentOrange, size: 20.0),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DELIVER TO',
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              order.deliveryAddress,
                              style: const TextStyle(
                                color: _textWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  const Divider(color: _borderColor, height: 1.0),
                  const SizedBox(height: 12.0),

                  // Items summary
                  const Text(
                    'ITEMS TO COLLECT',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    order.itemsSummary,
                    style: const TextStyle(
                      color: _textWhite,
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  // Action button based on status
                  // ค้นหาฟังก์ชัน _buildActiveTaskDetails แล้วแก้ช่วงปุ่มกดเป็นอันนี้ครับ
                  if (order.status == 'PREPARING' || order.status == 'READY' || order.status == 'DELIVERING')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: order.status == 'PREPARING' ? Colors.grey : Colors.green,
                        disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: order.status == 'PREPARING' ? null : () async {
                        try {
                          if (order.status == 'READY') {
                            await ApiService().updateOrderStatus(order.id, 'DELIVERING');
                          } else if (order.status == 'DELIVERING') {
                            await ApiService().updateOrderStatus(order.id, 'COMPLETED');
                            _tabController.animateTo(0); // เรียกตรงจาก controller ไม่ใช้ context
                          }
                          setState(() {
                            _activeTaskFuture = ApiService().fetchActiveTask(1);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: Text(
                        order.status == 'PREPARING' ? 'WAITING FOR FOOD' :
                        order.status == 'READY' ? 'MARK AS PICKED UP' : 'MARK AS DELIVERED',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    )
                ],
              ),
            ),
          ),
        ),
      ],
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

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF242C3F) // Road color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    // Draw grid roads
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), paint);

    // Draw glowing active routing path
    final routePaint = Paint()
      ..color = const Color(0xFF39FF14) // Neon green routing path
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.5) // Center (Rider position)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.7, size.height * 0.25); // Destination (Merchant/Customer position)
    
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

