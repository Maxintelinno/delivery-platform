import 'dart:async';
import 'package:flutter/material.dart';
import 'merchant_details_screen.dart';
import 'category_screen.dart';
import 'flash_deals_screen.dart';
import '../models/merchant_model.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _currentBannerIndex = 0;
  Timer? _bannerAutoScrollTimer;

  String _selectedFilter = 'Promo';

  int _countdownSeconds = 2712; // 45 minutes and 12 seconds
  Timer? _countdownTimer;

  final Set<String> _favoriteMerchants = {};

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': '50% OFF',
      'subtitle': 'On your first Food order!',
      'code': 'Use code: SUPER50',
      'emoji': '🍔',
      'colors': const [Color(0xFFFF8A65), Color(0xFFFF5722)],
    },
    {
      'title': 'Free Delivery',
      'subtitle': 'Zero delivery fees on groceries.',
      'code': 'Orders above ฿300',
      'emoji': '🍎',
      'colors': const [Color(0xFF81C784), Color(0xFF388E3C)],
    },
    {
      'title': 'Fast Express',
      'subtitle': 'Deliver documents in 20 min.',
      'code': 'Rates from ฿40',
      'emoji': '📦',
      'colors': const [Color(0xFF64B5F6), Color(0xFF1976D2)],
    },
  ];

  final List<Map<String, dynamic>> _mainServices = [
    {
      'title': 'Food',
      'icon': Icons.restaurant,
      'bgColor': const Color(0xFFFFECE8),
      'iconColor': const Color(0xFFFF5722),
    },
    {
      'title': 'Mart',
      'icon': Icons.shopping_bag,
      'bgColor': const Color(0xFFE8F5E9),
      'iconColor': const Color(0xFF43A047),
    },
    {
      'title': 'Express',
      'icon': Icons.delivery_dining,
      'bgColor': const Color(0xFFE3F2FD),
      'iconColor': const Color(0xFF1E88E5),
    },
    {
      'title': 'Parcel',
      'icon': Icons.inventory_2,
      'bgColor': const Color(0xFFFFF8E1),
      'iconColor': const Color(0xFFFFB300),
    },
    {
      'title': 'Ride',
      'icon': Icons.directions_car,
      'bgColor': const Color(0xFFF3E5F5),
      'iconColor': const Color(0xFF8E24AA),
    },
    {
      'title': 'Dine-In',
      'icon': Icons.local_dining,
      'bgColor': const Color(0xFFE0F2F1),
      'iconColor': const Color(0xFF00897B),
    },
    {
      'title': 'Bills',
      'icon': Icons.receipt,
      'bgColor': const Color(0xFFE8EAF6),
      'iconColor': const Color(0xFF3F51B5),
    },
    {
      'title': 'More',
      'icon': Icons.grid_view,
      'bgColor': const Color(0xFFECEFF1),
      'iconColor': const Color(0xFF607D8B),
    },
  ];

  final List<Map<String, dynamic>> _flashDeals = [
    {
      'id': 1,
      'name': 'Burger King',
      'emoji': '🍔',
      'discount': '50% OFF',
      'oldPrice': '฿250',
      'newPrice': '฿125',
      'rating': 4.5,
      'distance': '1.2 km',
      'tags': const ['Burgers', 'Fast Food'],
      'time': '15-20 min',
      'fee': 'Free',
      'colors': const [Color(0xFFFF9E80), Color(0xFFFF3D00)],
    },
    {
      'id': 1,
      'name': 'KFC Combo Deal',
      'emoji': '🍗',
      'discount': 'Save ฿50',
      'oldPrice': '฿299',
      'newPrice': '฿249',
      'rating': 4.6,
      'distance': '2.5 km',
      'tags': const ['Chicken', 'Fast Food'],
      'time': '20-25 min',
      'fee': '฿30',
      'colors': const [Color(0xFFFF8A80), Color(0xFFFF1744)],
    },
    {
      'id': 1,
      'name': 'Sushi House',
      'emoji': '🍣',
      'discount': 'Buy 1 Get 1',
      'oldPrice': '฿380',
      'newPrice': '฿190',
      'rating': 4.8,
      'distance': '0.9 km',
      'tags': const ['Sushi', 'Japanese'],
      'time': '10-15 min',
      'fee': 'Free',
      'colors': const [Color(0xFFFF80AB), Color(0xFFF50057)],
    },
  ];



  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Auto scroll banners
    _bannerAutoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextIdx = (_currentBannerIndex + 1) % _promoBanners.length;
        _pageController.animateToPage(
          nextIdx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });

    // Countdown Timer ticks
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAutoScrollTimer?.cancel();
    _countdownTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    return '$hStr:$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sticky SliverAppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 124.0,
            toolbarHeight: 60.0,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delivery Address Pill
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DELIVER TO',
                        style: TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: theme.primaryColor,
                            size: 15.0,
                          ),
                          const SizedBox(width: 4.0),
                          const Flexible(
                            child: Text(
                              '123 Sukhumvit Rd, Bangkok',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF212121),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2.0),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                            size: 16.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Notifications icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          color: Color(0xFF212121),
                          size: 24.0,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 10.0,
                        right: 10.0,
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                child: Container(
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                        size: 20.0,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          'Search food, mart, parcel...',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.tune,
                        color: Color(0xFF6B7280),
                        size: 20.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Promo Banner Carousel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 160.0,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _promoBanners.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentBannerIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final banner = _promoBanners[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: banner['colors'] as List<Color>,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              banner['title'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              banner['subtitle'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 10.0),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 4.0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                              child: Text(
                                                banner['code'] as String,
                                                style: TextStyle(
                                                  color: banner['colors'][1] as Color,
                                                  fontSize: 11.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          banner['emoji'] as String,
                                          style: const TextStyle(fontSize: 55.0),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _promoBanners.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: _currentBannerIndex == index ? 16.0 : 6.0,
                        height: 6.0,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          color: _currentBannerIndex == index
                              ? theme.primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Main Services Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final service = _mainServices[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(categoryName: service['title'] as String),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: service['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(18.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            service['icon'] as IconData,
                            color: service['iconColor'] as Color,
                            size: 26.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          service['title'] as String,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
                childCount: _mainServices.length,
              ),
            ),
          ),

          // 4. Quick Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: ['Promo', 'Free Delivery', 'Near Me', 'Top Rated'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                    child: ActionChip(
                      label: Text(filter),
                      onPressed: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: isSelected ? theme.primaryColor : Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 5. Flash Deals Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  // Header row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Flash Deals',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            // Countdown Timer
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(color: Colors.red.shade100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled,
                                    color: Colors.red,
                                    size: 13.0,
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    _formatCountdown(_countdownSeconds),
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FlashDealsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // Deals horizontal cards list
                  SizedBox(
                    height: 200.0,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _flashDeals.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14.0),
                      itemBuilder: (context, index) {
                        final deal = _flashDeals[index];
                        return Container(
                          width: 145.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MerchantDetailsScreen(merchantId: deal['id'] ?? 1),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        height: 95.0,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: deal['colors'] as List<Color>,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            deal['emoji'] as String,
                                            style: const TextStyle(fontSize: 40.0),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8.0,
                                        left: 8.0,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6.0,
                                            vertical: 3.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            deal['discount'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          deal['name'] as String,
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[850],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3.0),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 12.0,
                                            ),
                                            const SizedBox(width: 2.0),
                                            Text(
                                              deal['rating'].toString(),
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[650],
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              '• ${deal['distance']}',
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Text(
                                              deal['newPrice'] as String,
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              deal['oldPrice'] as String,
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: Colors.grey[400],
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Popular Near You Section (Title Row)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 28.0, bottom: 8.0),
              child: Text(
                'Popular Near You',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // Detailed Merchants Vertical List
          FutureBuilder<List<Merchant>>(
            future: ApiService().fetchMerchants(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Error loading merchants: ${snapshot.error}'),
                    ),
                  ),
                );
              }
              final merchants = snapshot.data ?? [];
              if (merchants.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No merchants available'),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final merchant = merchants[index];
                      final isFavorite = _favoriteMerchants.contains(merchant.name);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10.0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MerchantDetailsScreen(merchantId: merchant.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cover background gradient
                                Stack(
                                  children: [
                                    Container(
                                      height: 135.0,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: merchant.colors,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          merchant.emoji,
                                          style: const TextStyle(fontSize: 55.0),
                                        ),
                                      ),
                                    ),
                                    // Favorite Toggle Circle
                                    Positioned(
                                      top: 12.0,
                                      right: 12.0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (isFavorite) {
                                              _favoriteMerchants.remove(merchant.name);
                                            } else {
                                              _favoriteMerchants.add(merchant.name);
                                            }
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: isFavorite ? Colors.red : Colors.grey[500],
                                            size: 18.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Details
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              merchant.name,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF212121),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0,
                                              vertical: 3.0,
                                            ),
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
                                                  size: 13.0,
                                                ),
                                                const SizedBox(width: 3.0),
                                                Text(
                                                  merchant.rating.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      // Stats Row
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14.0,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 3.0),
                                          Text(
                                            merchant.distance,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Icon(
                                            Icons.access_time,
                                            size: 14.0,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 3.0),
                                          Text(
                                            merchant.time,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                            '•',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Icon(
                                            Icons.delivery_dining_outlined,
                                            size: 15.0,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 3.0),
                                          Text(
                                            merchant.fee == 'Free'
                                                ? 'Free Delivery'
                                                : 'Fee: ${merchant.fee}',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: merchant.fee == 'Free'
                                                  ? Colors.green[600]
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12.0),
                                      // Tags Wrap
                                      Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children: merchant.tags
                                            .map((tag) => Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 3.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(6.0),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 10.0,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: merchants.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}