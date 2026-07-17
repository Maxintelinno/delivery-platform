import 'package:flutter/material.dart';
import 'merchant_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String _selectedFilter = 'Sort';
  int _selectedSubCategoryIndex = 0;

  // Sub-categories list helper
  List<Map<String, String>> _getSubCategories() {
    if (widget.categoryName.toLowerCase() == 'food') {
      return [
        {'name': 'All', 'emoji': '🍽️'},
        {'name': 'Burgers', 'emoji': '🍔'},
        {'name': 'Chicken', 'emoji': '🍗'},
        {'name': 'Pizza', 'emoji': '🍕'},
        {'name': 'Asian', 'emoji': '🍣'},
        {'name': 'Healthy', 'emoji': '🥗'},
        {'name': 'Desserts', 'emoji': '🍩'},
        {'name': 'Drinks', 'emoji': '🧋'},
      ];
    } else if (widget.categoryName.toLowerCase() == 'mart') {
      return [
        {'name': 'All', 'emoji': '🛒'},
        {'name': 'Groceries', 'emoji': '🥬'},
        {'name': 'Snacks', 'emoji': '🍿'},
        {'name': 'Fruits', 'emoji': '🍎'},
        {'name': 'Drinks', 'emoji': '🥤'},
        {'name': 'Bakery', 'emoji': '🍞'},
        {'name': 'Household', 'emoji': '🧼'},
      ];
    } else {
      return [
        {'name': 'All', 'emoji': '✨'},
        {'name': 'Popular', 'emoji': '⭐'},
        {'name': 'New', 'emoji': '🔥'},
        {'name': 'Deals', 'emoji': '🏷️'},
        {'name': 'Trending', 'emoji': '📈'},
      ];
    }
  }

  // Merchants list helper
  List<Map<String, dynamic>> _getMerchants() {
    if (widget.categoryName.toLowerCase() == 'food') {
      return [
        {
          'name': 'Aroma Cafe & Bistro',
          'rating': 4.8,
          'time': '15-20 min',
          'fee': 'Free',
          'emoji': '☕',
          'distance': '1.5 km',
          'tags': const ['Coffee', 'Bakery', 'Desserts'],
          'colors': const [Color(0xFFFF8A65), Color(0xFFFF5722)],
        },
        {
          'name': 'Burger King',
          'rating': 4.5,
          'time': '15-20 min',
          'fee': 'Free',
          'emoji': '🍔',
          'distance': '1.2 km',
          'tags': const ['Burgers', 'Fast Food'],
          'colors': const [Color(0xFFFF9E80), Color(0xFFFF3D00)],
        },
        {
          'name': 'KFC Combo Deal',
          'rating': 4.6,
          'time': '20-25 min',
          'fee': '฿30',
          'emoji': '🍗',
          'distance': '2.5 km',
          'tags': const ['Chicken', 'Fast Food'],
          'colors': const [Color(0xFFFF8A80), Color(0xFFFF1744)],
        },
        {
          'name': 'The Pizzeria',
          'rating': 4.6,
          'time': '25-30 min',
          'fee': 'Free',
          'emoji': '🍕',
          'distance': '1.8 km',
          'tags': const ['Pizza', 'Italian', 'Pasta'],
          'colors': const [Color(0xFFFFD54F), Color(0xFFFFB300)],
        },
        {
          'name': 'Sushi House',
          'rating': 4.8,
          'time': '10-15 min',
          'fee': 'Free',
          'emoji': '🍣',
          'distance': '0.9 km',
          'tags': const ['Sushi', 'Japanese'],
          'colors': const [Color(0xFFFF80AB), Color(0xFFF50057)],
        },
        {
          'name': 'Healthy Bowl',
          'rating': 4.5,
          'time': '10-15 min',
          'fee': '฿20',
          'emoji': '🥗',
          'distance': '0.8 km',
          'tags': const ['Salads', 'Healthy', 'Vegetarian'],
          'colors': const [Color(0xFF4DB6AC), Color(0xFF009688)],
        },
      ];
    } else if (widget.categoryName.toLowerCase() == 'mart') {
      return [
        {
          'name': 'FreshMart Express',
          'rating': 4.7,
          'time': '10-15 min',
          'fee': '฿20',
          'emoji': '🍎',
          'distance': '2.1 km',
          'tags': const ['Groceries', 'Fruits', 'Organic'],
          'colors': const [Color(0xFF81C784), Color(0xFF43A047)],
        },
        {
          'name': 'SuperSave Groceries',
          'rating': 4.4,
          'time': '25-35 min',
          'fee': '฿10',
          'emoji': '🥬',
          'distance': '3.5 km',
          'tags': const ['Supermarket', 'Household'],
          'colors': const [Color(0xFF4DD6A7), Color(0xFF00A86B)],
        },
        {
          'name': 'Daily Bakery & Snack',
          'rating': 4.8,
          'time': '15-20 min',
          'fee': 'Free',
          'emoji': '🍞',
          'distance': '1.0 km',
          'tags': const ['Snacks', 'Bread', 'Desserts'],
          'colors': const [Color(0xFFFFD180), Color(0xFFFFAB40)],
        },
        {
          'name': 'Fruit & Veggie Land',
          'rating': 4.6,
          'time': '12-18 min',
          'fee': '฿15',
          'emoji': '🍉',
          'distance': '1.7 km',
          'tags': const ['Fruits', 'Vegetables', 'Fresh'],
          'colors': const [Color(0xFFE8F5E9), Color(0xFF66BB6A)],
        },
      ];
    } else {
      return [
        {
          'name': 'QuickDocs Courier',
          'rating': 4.9,
          'time': '20-25 min',
          'fee': '฿40',
          'emoji': '📄',
          'distance': '3.0 km',
          'tags': const ['Documents', 'Express', 'Courier'],
          'colors': const [Color(0xFF64B5F6), Color(0xFF1E88E5)],
        },
        {
          'name': 'Pioneer Delivery Services',
          'rating': 4.7,
          'time': '15-25 min',
          'fee': '฿30',
          'emoji': '📦',
          'distance': '2.2 km',
          'tags': const ['Parcels', 'Express', 'Logistic'],
          'colors': const [Color(0xFFCE93D8), Color(0xFFAB47BC)],
        },
        {
          'name': 'Urban Speed Transport',
          'rating': 4.8,
          'time': '10-15 min',
          'fee': '฿50',
          'emoji': '🛵',
          'distance': '1.3 km',
          'tags': const ['Rides', 'Motorcycle', 'Fast'],
          'colors': const [Color(0xFF80DEEA), Color(0xFF26C6DA)],
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subCategories = _getSubCategories();
    final merchants = _getMerchants();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. SliverAppBar (pinned: true)
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF212121),
            centerTitle: true,
            title: Text(
              widget.categoryName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching in ${widget.categoryName}...')),
                  );
                },
              ),
            ],
          ),

          // 2. Quick Filters Row (SliverToBoxAdapter)
          SliverToBoxAdapter(
            child: Container(
              height: 48.0,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: ['Sort', 'Nearest', 'Promo', 'Top Rated'].map((filter) {
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
                      backgroundColor: isSelected ? theme.primaryColor : const Color(0xFFF3F4F6),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF4B5563),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 3. Sub-categories row (SliverToBoxAdapter)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              height: 110.0,
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: subCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 20.0),
                itemBuilder: (context, index) {
                  final sub = subCategories[index];
                  final isSelected = _selectedSubCategoryIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSubCategoryIndex = index;
                      });
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 54.0,
                          height: 54.0,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withOpacity(0.12)
                                : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? theme.primaryColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              sub['emoji']!,
                              style: const TextStyle(fontSize: 24.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          sub['name']!,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? theme.primaryColor : const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Content List (SliverPadding + SliverList)
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final merchant = merchants[index];
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
                              builder: (context) => MerchantDetailsScreen(merchantId: merchant['id'] ?? 1),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Large food/product cover image placeholder
                            Container(
                              height: 140.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: merchant['colors'] as List<Color>,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  merchant['emoji'] as String,
                                  style: const TextStyle(fontSize: 60.0),
                                ),
                              ),
                            ),
                            // Details Section
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
                                          merchant['name'] as String,
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
                                              merchant['rating'].toString(),
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
                                  // Stats Row (Distance, Time, Fee)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 14.0,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 3.0),
                                      Text(
                                        merchant['distance'] as String,
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
                                        merchant['time'] as String,
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
                                        merchant['fee'] == 'Free'
                                            ? 'Free Delivery'
                                            : 'Fee: ${merchant['fee']}',
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: merchant['fee'] == 'Free'
                                              ? Colors.green[600]
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  // Category Tags
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: (merchant['tags'] as List<String>)
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
          ),
        ],
      ),
    );
  }
}
