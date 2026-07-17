import 'package:flutter/material.dart';

class FlashDealsScreen extends StatelessWidget {
  const FlashDealsScreen({super.key});

  // Mock deals catalog
  static const List<Map<String, dynamic>> _dealsCatalog = [
    {
      'name': 'Double Cheese Pizza',
      'emoji': '🍕',
      'discount': '40% OFF',
      'oldPrice': '฿320',
      'newPrice': '฿189',
      'rating': 4.7,
      'colors': [Color(0xFFFFB74D), Color(0xFFFF9800)],
    },
    {
      'name': 'Boba Milk Tea',
      'emoji': '🧋',
      'discount': 'Buy 1 Get 1',
      'oldPrice': '฿150',
      'newPrice': '฿75',
      'rating': 4.6,
      'colors': [Color(0xFFBCAAA4), Color(0xFF8D6E63)],
    },
    {
      'name': 'Matcha Glazed Donut',
      'emoji': '🍩',
      'discount': '50% OFF',
      'oldPrice': '฿80',
      'newPrice': '฿40',
      'rating': 4.8,
      'colors': [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
    },
    {
      'name': 'Spicy Wings Box',
      'emoji': '🍗',
      'discount': 'Save ฿60',
      'oldPrice': '฿220',
      'newPrice': '฿160',
      'rating': 4.5,
      'colors': [Color(0xFFEF9A9A), Color(0xFFEF5350)],
    },
    {
      'name': 'Salmon Sushi Platter',
      'emoji': '🍣',
      'discount': '30% OFF',
      'oldPrice': '฿450',
      'newPrice': '฿315',
      'rating': 4.9,
      'colors': [Color(0xFFF48FB1), Color(0xFFEC407A)],
    },
    {
      'name': 'Creamy Carbonara',
      'emoji': '🍝',
      'discount': '25% OFF',
      'oldPrice': '฿260',
      'newPrice': '฿195',
      'rating': 4.4,
      'colors': [Color(0xFFFFF59D), Color(0xFFFBC02D)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Flash Deals'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14.0,
          mainAxisSpacing: 14.0,
        ),
        itemCount: _dealsCatalog.length,
        itemBuilder: (context, index) {
          final deal = _dealsCatalog[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Thumbnail and Discount overlay badge
                Stack(
                  children: [
                    Container(
                      height: 110.0,
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
                          style: const TextStyle(fontSize: 48.0),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10.0,
                      left: 10.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          deal['discount'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Text details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal['name'] as String,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3.0),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 13.0),
                            const SizedBox(width: 3.0),
                            Text(
                              deal['rating'].toString(),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deal['newPrice'] as String,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  deal['oldPrice'] as String,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey[400],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: const Text(
                                'Claim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
