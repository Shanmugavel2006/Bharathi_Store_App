import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class UserCategoryPage extends StatefulWidget {
  const UserCategoryPage({super.key});

  @override
  State<UserCategoryPage> createState() => _UserCategoryPageState();
}

class _UserCategoryPageState extends State<UserCategoryPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Categories', 
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E1E), 
              fontWeight: FontWeight.bold, 
              fontSize: 18
            )
          ),
          actions: [
            IconButton(icon: Icon(Icons.search, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)), onPressed: () {}),
            IconButton(icon: Icon(Icons.mic, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)), onPressed: () {}),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('filters').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No categories available', style: TextStyle(color: isDark ? Colors.white : Colors.black)));
            }

            final categories = snapshot.data!.docs.map((doc) => doc['name'] as String).toList();
            _selectedCategory ??= categories.first;

            return Row(
              children: [
                // Left Side Panel
                Container(
                  width: 100,
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _selectedCategory == categories[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = categories[index];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                              ? (isDark ? const Color(0xFF094D22).withOpacity(0.3) : const Color(0xFFE5F5E9)) 
                              : (isDark ? const Color(0xFF121212) : Colors.white),
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) : Colors.transparent,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected 
                                    ? (isDark ? const Color(0xFF81C784).withOpacity(0.2) : const Color(0xFF98F598).withOpacity(0.3)) 
                                    : (isDark ? Colors.grey[900] : const Color(0xFFF3F4F6)),
                                ),
                                child: Icon(
                                  _getCategoryIcon(categories[index]),
                                  color: isSelected 
                                    ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
                                    : (isDark ? Colors.grey[600] : const Color(0xFF8B7A7B)),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                categories[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected 
                                    ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
                                    : (isDark ? Colors.grey[500] : const Color(0xFF6B7280)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Right Side Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCategory!,
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? Colors.white : const Color(0xFF1E1E1E)
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .where('category', isEqualTo: _selectedCategory)
                                .snapshots(),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
                                return Center(child: Text('No products in this category', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey)));
                              }

                              final products = productSnapshot.data!.docs;

                              return GridView.builder(
                                itemCount: products.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.65, // Increased vertical space to prevent overflow
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products[index].data() as Map<String, dynamic>;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 32,
                                          backgroundColor: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6),
                                          backgroundImage: NetworkImage(product['imageUrl'] ?? ''),
                                          onBackgroundImageError: (e, s) {},
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        product['title'] ?? 'Product',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10, 
                                          fontWeight: FontWeight.w600, 
                                          color: isDark ? Colors.grey[400] : const Color(0xFF4B5563)
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    category = category.toLowerCase();
    if (category.contains('fruit') || category.contains('veggie')) return Icons.apple;
    if (category.contains('dairy') || category.contains('bakery')) return Icons.egg;
    if (category.contains('staple')) return Icons.rice_bowl;
    if (category.contains('snack')) return Icons.fastfood;
    if (category.contains('beverage')) return Icons.local_drink;
    if (category.contains('household')) return Icons.cleaning_services;
    return Icons.category;
  }
}
