import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'user_shop_page.dart';
import 'user_category_page.dart';
import 'user_profile_page.dart';
import 'user_cart_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  final List<int> _navigationQueue = [0];

  final List<Widget> _pages = [
    const UserShopPage(),
    const UserCategoryPage(),
    const UserCartPage(),
    const UserProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _navigationQueue.remove(index);
        _navigationQueue.add(index);
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: () async {
        if (_navigationQueue.length > 1) {
          setState(() {
            _navigationQueue.removeLast();
            _selectedIndex = _navigationQueue.last;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
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
                _buildNavItem(0, Icons.home, 'HOME', isDark),
                _buildNavItem(1, Icons.grid_view, 'CATEGORIES', isDark),
                _buildNavItem(2, Icons.shopping_cart_outlined, 'CART', isDark),
                _buildNavItem(3, Icons.person_outline, 'ACCOUNT', isDark),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: null, // Background removed for consistency
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected
                ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))
                : (isDark ? Colors.grey[500] : const Color(0xFF8B7A7B).withOpacity(0.8)),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                  ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))
                  : (isDark ? Colors.grey[500] : const Color(0xFF8B7A7B).withOpacity(0.8)),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
