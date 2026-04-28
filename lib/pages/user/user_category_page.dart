import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../providers/theme_provider.dart';

import '../login_page.dart';
import 'user_address_page.dart';
import 'user_cart_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCategoryPage extends StatefulWidget {
  const UserCategoryPage({super.key});

  @override
  State<UserCategoryPage> createState() => _UserCategoryPageState();
}

class _UserCategoryPageState extends State<UserCategoryPage> {
  String? _selectedCategory;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> _addToCart(Map<String, dynamic> product, {Map<String, dynamic>? variant}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final itemTitle = variant != null 
      ? "${product['title']} (${variant['title']}${variant['unitValue'] != null && variant['unitValue'].toString().isNotEmpty ? ' - ${variant['unitValue']}${variant['unitType']}' : ''})" 
      : "${product['title']}${product['unitValue'] != null && product['unitValue'].toString().isNotEmpty ? ' (${product['unitValue']}${product['unitType']})' : ''}";
    final itemPrice = variant != null ? "₹ ${variant['price']}" : product['price'];
    final itemImage = (variant != null && variant['imageUrl'] != null && variant['imageUrl'].isNotEmpty) ? variant['imageUrl'] : product['imageUrl'];

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      final existing = await cartRef.where('title', isEqualTo: itemTitle).get();
      
      if (existing.docs.isNotEmpty) {
        await cartRef.doc(existing.docs.first.id).update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        await cartRef.add({
          'title': itemTitle,
          'price': itemPrice,
          'imageUrl': itemImage,
          'quantity': 1,
          'tag': product['tag'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$itemTitle added to cart'),
            backgroundColor: const Color(0xFF094D22),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: $e')),
        );
      }
    }
  }

  void _buyNow(Map<String, dynamic> product, {Map<String, dynamic>? variant}) async {
    await _addToCart(product, variant: variant);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserAddressPage()),
      );
    }
  }

  void _handleProductTap(Map<String, dynamic> product, {bool isBuyNow = false}) {
    if (product['hasVariants'] == true && product['variants'] != null) {
      _showVariantSelection(product);
    } else {
      if (isBuyNow) {
        _buyNow(product);
      } else {
        _addToCart(product);
      }
    }
  }

  void _showVariantSelection(Map<String, dynamic> product) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final List variants = product['variants'] as List;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Option for ${product['title']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF094D22)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: variants.length,
                itemBuilder: (context, index) {
                  final variant = variants[index] as Map<String, dynamic>;
                  final isVAvail = variant['isAvailable'] != false;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (variant['imageUrl'] != null && variant['imageUrl'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(variant['imageUrl'], width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image)),
                              )
                            else
                              Container(
                                width: 60, height: 60,
                                decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(variant['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text('₹ ${variant['price']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                                      if (variant['unitValue'] != null && variant['unitValue'].toString().isNotEmpty)
                                         Text(' / ${variant['unitValue']}${variant['unitType']}', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                     ],
                                   ),
                                   const SizedBox(height: 4),
                                   Row(
                                     children: [
                                       Container(width: 6, height: 6, decoration: BoxDecoration(color: !isVAvail ? Colors.red : Colors.green, shape: BoxShape.circle)),
                                       const SizedBox(width: 4),
                                       Text(
                                         !isVAvail ? 'UNAVAILABLE' : 'AVAILABLE',
                                         style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: !isVAvail ? Colors.red : (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
                                       ),
                                     ],
                                   ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: !isVAvail ? null : () {
                                  Navigator.pop(context);
                                  _addToCart(product, variant: variant);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: !isVAvail ? Colors.grey : const Color(0xFF094D22)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Add Cart', style: TextStyle(color: !isVAvail ? Colors.grey : const Color(0xFF094D22))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: !isVAvail ? null : () {
                                  Navigator.pop(context);
                                  _buyNow(product, variant: variant);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !isVAvail ? Colors.grey[300] : const Color(0xFF094D22),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(!isVAvail ? 'Unavailable' : 'Buy Now', style: TextStyle(color: !isVAvail ? Colors.grey[600] : Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startListening() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Icon(Icons.mic, size: 48, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
              const SizedBox(height: 16),
              Text(
                'Listening...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1E1E)),
              ),
              const SizedBox(height: 8),
              Text(
                'Say the product name',
                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : const Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ).whenComplete(() {
        _speech.stop();
        setState(() => _isListening = false);
      });

      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _searchQuery = result.recognizedWords;
              _searchController.text = result.recognizedWords;
              _isSearching = true;
              _isListening = false;
            });
            if (Navigator.canPop(context)) Navigator.pop(context);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
      }
    }
  }

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
          leading: Navigator.canPop(context) ? IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
            onPressed: () => Navigator.maybePop(context),
          ) : null,
          title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E1E1E), fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[600] : const Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                ),
              )
            : Text(
                'Categories', 
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E1E1E), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 18
                )
              ),
          actions: [
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search, 
                color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
              ), 
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _isSearching = false;
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)),
              ), 
              onPressed: _startListening,
            ),
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
            categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
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

                              final products = productSnapshot.data!.docs.where((doc) {
                                if (_searchQuery.isEmpty) return true;
                                final title = (doc.data() as Map<String, dynamic>)['title'] as String? ?? '';
                                return title.toLowerCase().contains(_searchQuery.toLowerCase());
                              }).toList();

                              return GridView.builder(
                                itemCount: products.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                itemBuilder: (context, index) {
                                  final product = products[index].data() as Map<String, dynamic>;
                                  final isAvailable = product['isAvailable'] ?? true;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () => _handleProductTap(product),
                                                child: Container(
                                                  decoration: BoxDecoration(color: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                                                  width: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(12),
                                                    child: Image.network(
                                                      product['imageUrl'] ?? '',
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image, color: isDark ? Colors.grey[800] : Colors.grey)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (!isAvailable)
                                                Container(
                                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                                  alignment: Alignment.center,
                                                  child: const Text('OUT OF\nSTOCK', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(product['title'] ?? 'Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : const Color(0xFF1E1E1E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text(product['price'] ?? '₹0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: isAvailable ? () => _handleProductTap(product) : null,
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: isAvailable ? const Color(0xFF094D22) : (isDark ? Colors.grey[900] : const Color(0xFFE5E7EB)),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(isAvailable ? 'Add' : 'Notify', style: TextStyle(color: isAvailable ? Colors.white : (isDark ? Colors.grey[700] : const Color(0xFF9CA3AF)), fontWeight: FontWeight.bold, fontSize: 11)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
