import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Top Section (User Profile Area)
            _buildProfileHeader(context),
            const SizedBox(height: 12.0),

            // 2. Body Settings Sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Group 1: Account
                  _buildSectionTitle('Account Details'),
                  _buildSettingsGroup(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        Icons.location_on_outlined,
                        'My Addresses',
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.credit_card_outlined,
                        'Payment Methods',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Group 2: Promotions & Support
                  _buildSectionTitle('Offers & Support'),
                  _buildSettingsGroup(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        Icons.local_offer_outlined,
                        'Vouchers & Offers',
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.help_center_outlined,
                        'Help Center',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Group 3: Preferences
                  _buildSectionTitle('Preferences'),
                  _buildSettingsGroup(
                    context,
                    children: [
                      _buildSettingsTile(
                        context,
                        Icons.language_outlined,
                        'App Language',
                        trailingValue: 'English',
                        onTap: () {},
                      ),
                      _buildSettingsTile(
                        context,
                        Icons.dark_mode_outlined,
                        'Dark Theme',
                        trailingValue: 'Off',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // Group 4: Log Out
                  _buildLogoutButton(context),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile Header block builder
  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 24.0, left: 20.0, right: 20.0, top: 12.0),
      child: Row(
        children: [
          // Circular Avatar Placeholder
          Container(
            width: 76.0,
            height: 76.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.25),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18.0),
          // User Details & Edit Profile action
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'john.doe@example.com • +66 81 234 5678',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10.0),
                // Edit Profile Chip Button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15.0),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 13.0,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  // Section Header title
  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Settings Card Group Wrapper
  Widget _buildSettingsGroup(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFF3F4F6),
        ),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  // Settings ListTile Component
  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? trailingValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.grey[700],
          size: 18.0,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Color(0xFF212121),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingValue != null)
            Text(
              trailingValue,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(width: 4.0),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[400],
            size: 20.0,
          ),
        ],
      ),
    );
  }

  // Red styled logout card button
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(context),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: Colors.red,
            size: 18.0,
          ),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.red,
          size: 20.0,
        ),
      ),
    );
  }

  // Log Out confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Successfully logged out!'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
