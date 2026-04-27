import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/theme_provider.dart';
import 'admin_orders_page.dart';
import 'admin_add_product_page.dart';
import 'admin_manage_items_page.dart';
import 'admin_users_page.dart';
import 'admin_dashboard_page.dart';
import 'admin_analysis_page.dart';
import 'admin_settings_page.dart';
import 'admin_history_page.dart';
import '../login_page.dart';

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
    const AdminHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = Provider.of<UserSettingsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: isDark ? Colors.white : const Color(0xFF094D22)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Bharathi Store Admin',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF094D22),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: isDark ? Colors.white : const Color(0xFF094D22)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF094D22),
              radius: 18,
              backgroundImage: NetworkImage(userSettings.profileImageUrl),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
            _buildDrawerItem(0, Icons.dashboard_outlined, 'Dashboard', isDark),
            _buildDrawerItem(1, Icons.receipt_long_outlined, 'Orders', isDark),
            _buildDrawerItem(3, Icons.inventory_2_outlined, 'Manage Items', isDark),
            _buildDrawerItem(4, Icons.add_box_outlined, 'Add Product', isDark),
            _buildDrawerItem(5, Icons.analytics_outlined, 'Analysis', isDark),
            _buildDrawerItem(7, Icons.history_outlined, 'History', isDark),
            _buildDrawerItem(2, Icons.people_outline, 'Users', isDark),
            const Spacer(),
            _buildDrawerItem(6, Icons.settings_outlined, 'Settings', isDark),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                Expanded(child: _buildNavItem(0, Icons.dashboard, 'DASH', isDark)),
                Expanded(child: _buildNavItem(1, Icons.receipt_long, 'ORDERS', isDark)),
                Expanded(child: _buildNavItem(3, Icons.inventory_2, 'ITEMS', isDark)),
                Expanded(child: _buildNavItem(2, Icons.people, 'USERS', isDark)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData, String label, bool isDark) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: isDark ? const Color(0xFF2E7D32).withOpacity(0.2) : const Color(0xFFE5F5E9),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected 
                ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
                : (isDark ? Colors.grey[500] : const Color(0xFF8B7A7B).withOpacity(0.8)),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
                  : (isDark ? Colors.grey[500] : const Color(0xFF8B7A7B).withOpacity(0.8)),
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

  Widget _buildDrawerItem(int index, IconData icon, String title, bool isDark) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected 
        ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
        : (isDark ? Colors.grey[400] : Colors.grey[600])),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected 
            ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
            : (isDark ? Colors.grey[300] : Colors.grey[800]),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: isDark ? const Color(0xFF2E7D32).withOpacity(0.1) : const Color(0xFFE5F5E9),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}
