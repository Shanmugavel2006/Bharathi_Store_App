import 'package:flutter/material.dart';
import 'admin_orders_page.dart';
import 'admin_add_product_page.dart';
import 'admin_manage_items_page.dart';
import 'admin_users_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_analysis_page.dart';
import 'admin_settings_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminOrdersPage(),
    const AdminUsersPage(),
    const AdminManageItemsPage(),
    const AdminAddProductPage(),
    const AdminAnalysisPage(),
    const AdminSettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF094D22)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Verdant Admin',
          style: TextStyle(
            color: Color(0xFF094D22),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF094D22),
              radius: 16,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF094D22)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.store, color: Color(0xFF094D22), size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text('Bharathi Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(0, Icons.dashboard_outlined, 'Dashboard'),
            _buildDrawerItem(1, Icons.receipt_long_outlined, 'Orders'),
            _buildDrawerItem(3, Icons.inventory_2_outlined, 'Manage Items'),
            _buildDrawerItem(4, Icons.add_box_outlined, 'Add Product'),
            _buildDrawerItem(5, Icons.analytics_outlined, 'Analysis'),
            _buildDrawerItem(2, Icons.people_outline, 'Users'),
            const Spacer(),
            _buildDrawerItem(6, Icons.settings_outlined, 'Settings'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildNavItem(0, Icons.dashboard, 'DASH')),
                Expanded(child: _buildNavItem(1, Icons.receipt_long, 'ORDERS')),
                Expanded(child: _buildNavItem(3, Icons.inventory_2, 'ITEMS')),
                Expanded(child: _buildNavItem(2, Icons.people, 'USERS')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFE5F5E9),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected ? const Color(0xFF094D22) : const Color(0xFF8B7A7B).withOpacity(0.8),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF094D22) : const Color(0xFF8B7A7B).withOpacity(0.8),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF094D22) : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF094D22) : Colors.grey[800],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: const Color(0xFFE5F5E9),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
