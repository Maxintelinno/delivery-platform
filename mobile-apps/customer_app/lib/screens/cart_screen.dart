import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'order_success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Flat fees
  static const int _deliveryFee = 20;

  // Calculators
  int _getSubtotal(CartProvider cart) {
    return cart.totalAmount.toInt();
  }

  int _getTotal(CartProvider cart) {
    final sub = _getSubtotal(cart);
    if (sub == 0) return 0;
    return sub + _deliveryFee;
  }

  void _incrementQuantity(CartProvider cart, CartItem item) {
    cart.addItem(item.id, item.title, item.price, item.imageUrl, item.merchantId, item.menuId);
  }

  void _decrementQuantity(CartProvider cart, String productId) {
    cart.decrementQuantity(productId);
  }

  // Action: Confirm order and navigate to success screen
  Future<void> _placeOrder(BuildContext context, CartProvider cart) async {
    final cartItems = cart.items.values.toList();
    if (cartItems.isEmpty) return;

    final int merchantId = cartItems.first.merchantId;
    final List<Map<String, dynamic>> apiItems = cartItems.map((item) => {
      'menuId': item.menuId,
      'quantity': item.quantity,
      'price': item.price,
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await ApiService().createOrder(
      merchantId: merchantId,
      items: apiItems,
      totalAmount: cart.totalAmount,
      paymentMethod: 'CASH',
      deliveryAddress: '123 Sukhumvit Rd, Bangkok, 10110',
    );

    if (context.mounted) {
      Navigator.pop(context);
    }

    if (success) {
      cart.clearCart();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderSuccessScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final cartItems = cart.items.values.toList();
    final totalAmount = _getTotal(cart);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Delivery Address Section
                  _buildAddressSection(context),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

                  // 2. Order Items Section Title
                  Text(
                    'Order Items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Order Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item, cart);
                    },
                  ),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

                  // 3. Payment Method Section
                  _buildPaymentSection(context),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),

                  // 4. Order Summary Receipt Section
                  _buildSummarySection(context, cart),
                  const SizedBox(height: 40.0), // Padding before bottom bar
                ],
              ),
            ),

      // 5. Bottom Action Bar (Sticky Checkout Button)
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Container(
                  height: 56.0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.35),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    onPressed: () => _placeOrder(context, cart),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '฿$totalAmount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Row(
                            children: [
                              Text(
                                'Place Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 14.0,
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
  }

  // Address Row Card Builder
  Widget _buildAddressSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: theme.primaryColor,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '123 Sukhumvit Rd, Bangkok, 10110',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cart Item Widget Builder
  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider cart) {
    final theme = Theme.of(context);
    final int itemTotal = (item.price * item.quantity).toInt();

    // Try to guess a description or fallback
    String desc = 'Delicious menu item';
    if (item.title.contains('Burger')) {
      desc = 'Wagyu beef patty, black truffle aioli';
    } else if (item.title.contains('Fries')) {
      desc = 'Golden fries with roasted garlic oil';
    } else if (item.title.contains('Wrap')) {
      desc = 'Grilled chicken and fresh avocado wrap';
    } else if (item.title.contains('Matcha')) {
      desc = 'Ceremonial Japanese matcha espresso latte';
    } else if (item.title.contains('Soufflé')) {
      desc = 'Belgium dark chocolate molten lava cake';
    } else if (item.title.contains('Lemonade')) {
      desc = 'Strawberry, sweet basil, and sparkling soda';
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Emoji Thumbnail Box
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Center(
              child: Text(
                item.imageUrl,
                style: const TextStyle(fontSize: 28.0),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Name and pricing details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Color(0xFF212121),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),
                Text(
                  '฿$itemTotal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Quantity selector widget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _decrementQuantity(cart, item.id),
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      size: 13.0,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _incrementQuantity(cart, item),
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 13.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Payment Method Row Card Builder
  Widget _buildPaymentSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: Colors.green,
            size: 20.0,
          ),
        ),
        title: const Text(
          'Cash on Delivery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13.5,
            color: Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          'Pay with cash upon arrival',
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.grey[500],
          ),
        ),
        trailing: GestureDetector(
          onTap: () {},
          child: Text(
            'Change',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13.0,
            ),
          ),
        ),
      ),
    );
  }

  // Summary Receipt Card Builder
  Widget _buildSummarySection(BuildContext context, CartProvider cart) {
    final theme = Theme.of(context);
    final int sub = _getSubtotal(cart);
    final int total = _getTotal(cart);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 14.0),
          _buildSummaryRow('Subtotal', '฿$sub', isBold: false),
          const SizedBox(height: 10.0),
          _buildSummaryRow('Delivery Fee', '฿$_deliveryFee', isBold: false),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
          _buildSummaryRow('Total', '฿$total', isBold: true, valueColor: theme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {required bool isBold, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15.0 : 13.0,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF212121) : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17.0 : 13.0,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: valueColor ?? (isBold ? const Color(0xFF212121) : Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  // Beautiful Empty State Widget
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                color: theme.primaryColor,
                size: 64.0,
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Looks like you haven\'t added anything to your cart yet. Explore popular meals near you!',
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                // Navigate back to Home screen using custom Notification
                const TabSwitchNotification(0).dispatch(context);
              },
              child: const Text(
                'Browse Restaurants',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabSwitchNotification extends Notification {
  final int tabIndex;
  const TabSwitchNotification(this.tabIndex);
}
