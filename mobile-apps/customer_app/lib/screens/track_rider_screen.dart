import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class TrackRiderScreen extends StatefulWidget {
  const TrackRiderScreen({super.key});

  @override
  State<TrackRiderScreen> createState() => _TrackRiderScreenState();
}

class _TrackRiderScreenState extends State<TrackRiderScreen> {
  String currentStatus = 'PENDING';
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
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
    socket.on('orderStatusUpdated', (data) {
      if (mounted) {
        setState(() {
          currentStatus = data['status'] ?? 'PENDING';
        });
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Mock Map Background Layer
          Positioned.fill(
            child: Container(
              color: const Color(0xFFE8ECEF), // light map-grey base
              child: CustomPaint(
                painter: MapGridPainter(),
              ),
            ),
          ),

          // Custom Map Markers Overlay
          Positioned(
            left: size.width * 0.18,
            top: size.height * 0.32,
            child: _buildMapMarker(
              label: 'Cafe Bistro',
              emoji: '☕',
              markerColor: theme.primaryColor,
            ),
          ),
          Positioned(
            left: size.width * 0.52,
            top: size.height * 0.22,
            child: _buildMapMarker(
              label: 'Somsak (Rider)',
              emoji: '🛵',
              markerColor: Colors.blue,
              isPulse: true,
            ),
          ),
          Positioned(
            right: size.width * 0.16,
            top: size.height * 0.15,
            child: _buildMapMarker(
              label: 'My Home',
              emoji: '🏠',
              markerColor: Colors.green,
            ),
          ),

          // 2. Floating Top Controls Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Floating Top ETA Banner
          Positioned(
            top: MediaQuery.of(context).padding.top + 12.0,
            left: 80.0,
            right: 80.0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10.0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_filled, color: theme.primaryColor, size: 18),
                    const SizedBox(width: 8.0),
                    const Text(
                      'Arrives in 15 mins',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Draggable Scrollable Bottom Status Sheet
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: 0.35,
              minChildSize: 0.35,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: const [0.35, 0.85],
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15.0,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
                    children: [
                      // Scroll Grab Handle
                      Center(
                        child: Container(
                          width: 44.0,
                          height: 5.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Rider Card
                      _buildRiderCard(context),
                      const Divider(height: 36, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Timeline Stepper Progress
                      const Text(
                        'Delivery Progress',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      _buildTimelineSection(context),
                      const Divider(height: 36, thickness: 1, color: Color(0xFFF3F4F6)),

                      // Condensed Order Summary
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      _buildOrderSummary(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builder: Interactive marker widget on the mock map
  Widget _buildMapMarker({
    required String label,
    required String emoji,
    required Color markerColor,
    bool isPulse = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Marker Pin
        Stack(
          alignment: Alignment.center,
          children: [
            if (isPulse)
              Container(
                width: 50.0,
                height: 50.0,
                decoration: BoxDecoration(
                  color: markerColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            Container(
              width: 38.0,
              height: 38.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        // Mini Label Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4.0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
        ),
      ],
    );
  }

  // Builder: Draggable Sheet Rider details section
  Widget _buildRiderCard(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        // circular avatar
        Stack(
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'SP',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2.0,
              bottom: 2.0,
              child: Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14.0),
        // Name & details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Somsak P.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                'Honda Click | 789',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Action Call & Chat Shortcuts
        _buildCircularActionButton(
          icon: Icons.phone_forwarded,
          color: Colors.green.shade50,
          iconColor: Colors.green,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling Somsak P...')),
            );
          },
        ),
        const SizedBox(width: 10.0),
        _buildCircularActionButton(
          icon: Icons.chat_bubble_outline,
          color: theme.primaryColor.withOpacity(0.08),
          iconColor: theme.primaryColor,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening live chat...')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircularActionButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.0,
        height: 42.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 18.0,
        ),
      ),
    );
  }

  // Builder: Draggable Sheet Status Tracker Timeline
  Widget _buildTimelineSection(BuildContext context) {
    TimelineStatus step1 = TimelineStatus.completed;
    TimelineStatus step2 = TimelineStatus.pending;
    TimelineStatus step3 = TimelineStatus.pending;
    TimelineStatus step4 = TimelineStatus.pending;
    TimelineStatus step5 = TimelineStatus.pending;

    if (currentStatus == 'PENDING') {
      step1 = TimelineStatus.active;
    } else if (currentStatus == 'PREPARING') {
      step1 = TimelineStatus.completed;
      step2 = TimelineStatus.active;
    } else if (currentStatus == 'DELIVERING') {
      step1 = TimelineStatus.completed;
      step2 = TimelineStatus.completed;
      step3 = TimelineStatus.completed;
      step4 = TimelineStatus.active;
    } else if (currentStatus == 'COMPLETED' || currentStatus == 'CANCELLED') {
      step1 = TimelineStatus.completed;
      step2 = TimelineStatus.completed;
      step3 = TimelineStatus.completed;
      step4 = TimelineStatus.completed;
      step5 = TimelineStatus.completed;
    }

    return Column(
      children: [
        _buildTimelineStep(
          title: 'Order Placed',
          time: currentStatus == 'PENDING' ? 'Active' : 'Completed',
          status: step1,
        ),
        _buildTimelineStep(
          title: 'Food Prepared & Ready',
          time: currentStatus == 'PREPARING' ? 'Preparing...' : '',
          status: step2,
        ),
        _buildTimelineStep(
          title: 'Rider Picked Up Order',
          time: '',
          status: step3,
        ),
        _buildTimelineStep(
          title: 'Rider is En Route',
          time: currentStatus == 'DELIVERING' ? 'On the way' : '',
          status: step4,
        ),
        _buildTimelineStep(
          title: 'Delivered',
          time: '',
          status: step5,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String time,
    required TimelineStatus status,
    bool isLast = false,
  }) {
    Color stepColor = Colors.grey.shade300;
    Widget dotWidget = const SizedBox.shrink();

    switch (status) {
      case TimelineStatus.completed:
        stepColor = Colors.green;
        dotWidget = const Icon(
          Icons.check,
          color: Colors.white,
          size: 12.0,
        );
        break;
      case TimelineStatus.active:
        stepColor = Colors.orange;
        dotWidget = Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        );
        break;
      case TimelineStatus.pending:
        stepColor = Colors.grey.shade300;
        dotWidget = const SizedBox.shrink();
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical Line Indicator column
          Column(
            children: [
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  color: stepColor,
                  shape: BoxShape.circle,
                  boxShadow: status == TimelineStatus.active
                      ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 8.0,
                            spreadRadius: 2.0,
                          ),
                        ]
                      : null,
                ),
                child: Center(child: dotWidget),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: status == TimelineStatus.completed ? Colors.green : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16.0),
          // Info column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: status == TimelineStatus.active ? FontWeight.bold : FontWeight.w600,
                      color: status == TimelineStatus.active
                          ? Colors.orange.shade800
                          : (status == TimelineStatus.pending ? Colors.grey[400] : const Color(0xFF212121)),
                    ),
                  ),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 3.0),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builder: Draggable Sheet order metadata details
  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Cafe Bistro Items', '1x Signature Truffle Burger, 2x Parmesan Fries'),
          const SizedBox(height: 10.0),
          _buildSummaryRow('Delivery To', '123 Sukhumvit Rd, Bangkok, 10110'),
          const SizedBox(height: 10.0),
          _buildSummaryRow('Subtotal + Fee', '฿410'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}

enum TimelineStatus {
  completed,
  active,
  pending,
}

// Painter: Draws Mock neighborhood paths and grid layers representing a digital map background
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.blue.withOpacity(0.6)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw main street paths
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.1),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.15, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.9, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.7),
      Offset(size.width * 0.9, size.height * 0.65),
      paint,
    );

    // Draw routing curve dotted route connecting cafe -> rider -> user
    final routePath = Path();
    routePath.moveTo(size.width * 0.18 + 19, size.height * 0.32 + 19);
    routePath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.28,
      size.width * 0.52 + 19,
      size.height * 0.22 + 19,
    );
    routePath.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.18,
      size.width - size.width * 0.16 - 19,
      size.height * 0.15 + 19,
    );

    // Manual dashed curve drawing
    final pathMetrics = routePath.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = metric.extractPath(distance, distance + 6.0);
        canvas.drawPath(length, dashPaint);
        distance += 12.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
