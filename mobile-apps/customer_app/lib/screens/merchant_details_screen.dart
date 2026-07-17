import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'cart_screen.dart';

class MerchantDetailsScreen extends StatelessWidget {
  final int merchantId;

  const MerchantDetailsScreen({
    super.key,
    required this.merchantId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService().fetchMerchantDetails(merchantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading details: ${snapshot.error}'),
              ),
            ),
          );
        }
        final merchant = snapshot.data;
        if (merchant == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: Text('Merchant not found'),
            ),
          );
        }

        final merchantColors = merchant['colors'] as List<Color>;
        final List<dynamic> menus = merchant['menus'] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. SliverAppBar (Cover Image Placeholder & Back Button)
              SliverAppBar(
                pinned: true,
                expandedHeight: 230.0,
                backgroundColor: merchantColors[1],
                surfaceTintColor: Colors.transparent,
                leadingWidth: 56.0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Center(
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16.0,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    margin: const EdgeInsets.only(right: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  title: Text(
                    merchant['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.5,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 1),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Signature Gradient Cover
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: merchantColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      // Diagonal decorative background shapes
                      Positioned(
                        right: -50,
                        top: -50,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      // Centered Merchant Cover Emoji
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20.0),
                            Text(
                              merchant['emoji'] as String,
                              style: const TextStyle(fontSize: 70.0),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                      // Dark bottom gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. SliverToBoxAdapter (Merchant Details Card)
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant Name and Cuisine Category
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  merchant['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  (merchant['tags'] as List<dynamic>).join(' • '),
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Rating and Reviews Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14.0,
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  merchant['rating'].toString(),
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            '4.8/5 Rating • 500+ Reviews',
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // Stats Row Cards (Distance, delivery time, fee)
                      Container(
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickInfo(
                              context,
                              Icons.location_on_outlined,
                              merchant['distance'] as String,
                              'Distance',
                            ),
                            Container(
                              width: 1.0,
                              height: 24.0,
                              color: Colors.grey[200],
                            ),
                            _buildQuickInfo(
                              context,
                              Icons.access_time,
                              merchant['time'] as String,
                              'Time',
                            ),
                            Container(
                              width: 1.0,
                              height: 24.0,
                              color: Colors.grey[200],
                            ),
                            _buildQuickInfo(
                              context,
                              Icons.delivery_dining_outlined,
                              merchant['fee'] == 'Free' ? 'Free' : (merchant['fee'] as String),
                              'Delivery Fee',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu section header title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
                  child: Text(
                    'Menu List',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),

              // 3. SliverList (Sleek Menu Items)
              menus.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text('No menu items available'),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final dish = menus[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6.0,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: Dish details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dish['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0,
                                            color: Color(0xFF212121),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          dish['desc']!,
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey[500],
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          '฿${dish['price']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15.0,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  // Right: Interactive image placeholder with add icon overlay
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 85.0,
                                        height: 85.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            dish['emoji']!,
                                            style: const TextStyle(fontSize: 36.0),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -4.0,
                                        right: -4.0,
                                        child: GestureDetector(
                                          onTap: () {
                                            final double price = (dish['price'] as num).toDouble();
                                            context.read<CartProvider>().addItem(
                                                  '${merchant['name']}_${dish['name']}',
                                                  dish['name']!,
                                                  price,
                                                  dish['emoji']!,
                                                  merchant['id'] as int,
                                                  dish['id'] as int,
                                                );

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Added ${dish['name']} to cart!'),
                                                duration: const Duration(seconds: 1),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 26.0,
                                            height: 26.0,
                                            decoration: BoxDecoration(
                                              color: theme.primaryColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.primaryColor.withOpacity(0.3),
                                                  blurRadius: 4.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 16.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: menus.length,
                        ),
                      ),
                    ),
              // Spacer at the bottom so elements don't get covered by floating cart bar
              const SliverToBoxAdapter(
                child: SizedBox(height: 100.0),
              ),
            ],
          ),
          // 4. Persistent bottomNavigationBar (Floating "View Cart" banner)
          bottomNavigationBar: Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.itemCount == 0) {
                return const SizedBox.shrink();
              }
              final int totalAmount = cart.totalAmount.toInt();
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                  child: Container(
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.35),
                          blurRadius: 10.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Cart Summary
                              Row(
                                children: [
                                  const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 22.0,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${cart.itemCount} Item${cart.itemCount > 1 ? 's' : ''} | ฿$totalAmount",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      Text(
                                        'From: ${merchant['name']}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // View Cart CTA
                              const Row(
                                children: [
                                  Text(
                                    'View Cart',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  SizedBox(width: 4.0),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 13.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickInfo(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 4.0),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
