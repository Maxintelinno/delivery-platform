import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy merchants list
    final List<Map<String, dynamic>> merchants = [
      {
        'name': 'Aroma Cafe & Bistro',
        'rating': 4.8,
        'time': '15-20 min',
        'fee': '\$1.49',
        'icon': Icons.restaurant,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'QuickDocs Courier Services',
        'rating': 4.9,
        'time': '20-25 min',
        'fee': '\$2.99',
        'icon': Icons.description,
        'gradient': const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'name': 'FreshMart Express Grocery',
        'rating': 4.7,
        'time': '10-15 min',
        'fee': '\$0.99',
        'icon': Icons.local_grocery_store,
        'gradient': const LinearGradient(
          colors: [Color(0xFF81C784), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    // Category list
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Food',
        'icon': Icons.fastfood,
        'color': const Color(0xFFFFE0B2),
        'iconColor': const Color(0xFFFF5722),
      },
      {
        'title': 'Documents',
        'icon': Icons.description,
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF1E88E5),
      },
      {
        'title': 'Mart',
        'icon': Icons.storefront,
        'color': const Color(0xFFE8F5E9),
        'iconColor': const Color(0xFF43A047),
      },
      {
        'title': 'Parcel',
        'icon': Icons.local_shipping,
        'color': const Color(0xFFEDE7F6),
        'iconColor': const Color(0xFF5E35B1),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deliver to',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '123 Sukhumvit Rd, Bangkok',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey[700],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Notification Button for aesthetic detail
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.grey[800],
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),

              // 2. Search Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search food, documents, etc.',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14.0,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 22,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 3. Categories Section
              SizedBox(
                height: 96.0,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 20.0),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: category['color'],
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Icon(
                              category['icon'],
                              color: category['iconColor'],
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            category['title'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24.0),

              // 4. Featured Merchants Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Near You',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Merchant Cards List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: merchants.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  final merchant = merchants[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1.0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Generic Image Placeholder Container
                          Container(
                            height: 130.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: merchant['gradient'],
                            ),
                            child: Center(
                              child: Icon(
                                merchant['icon'],
                                color: Colors.white.withOpacity(0.85),
                                size: 50.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        merchant['name'],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber[50],
                                        borderRadius: BorderRadius.circular(8.0),
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
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      size: 14.0,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      merchant['time'],
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      '•',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Icon(
                                      Icons.local_shipping,
                                      size: 14.0,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'Delivery: ${merchant['fee']}',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[600],
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
