import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../login_page.dart';
import 'user_address_page.dart';
import 'user_cart_page.dart';

class UserShopPage extends StatefulWidget {
  const UserShopPage({super.key});

  @override
  State<UserShopPage> createState() => _UserShopPageState();
}

class _UserShopPageState extends State<UserShopPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

      // Check if item already exists
      final existing = await cartRef.where('title', isEqualTo: itemTitle).get();
      
      if (existing.docs.isNotEmpty) {
        // Increment quantity
        await cartRef.doc(existing.docs.first.id).update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Add new item
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
                                       Container(width: 6, height: 6, decoration: BoxDecoration(color: variant['isAvailable'] == false ? Colors.red : Colors.green, shape: BoxShape.circle)),
                                       const SizedBox(width: 4),
                                       Text(
                                         variant['isAvailable'] == false ? 'UNAVAILABLE' : 'AVAILABLE',
                                         style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: variant['isAvailable'] == false ? Colors.red : (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
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
                                onPressed: variant['isAvailable'] == false ? null : () {
                                  Navigator.pop(context);
                                  _addToCart(product, variant: variant);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: variant['isAvailable'] == false ? Colors.grey : const Color(0xFF094D22)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Add Cart', style: TextStyle(color: variant['isAvailable'] == false ? Colors.grey : const Color(0xFF094D22))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: variant['isAvailable'] == false ? null : () {
                                  Navigator.pop(context);
                                  _buyNow(product, variant: variant);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: variant['isAvailable'] == false ? Colors.grey[300] : const Color(0xFF094D22),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(variant['isAvailable'] == false ? 'Unavailable' : 'Buy Now', style: TextStyle(color: variant['isAvailable'] == false ? Colors.grey[600] : Colors.white)),
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          title: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 45,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.store, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22), size: 40),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bharathi',
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Departmental Store',
                    style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF094D22), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white : const Color(0xFF094D22)), 
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCartPage()));
              }
            ),
            IconButton(
              icon: Icon(Icons.logout, color: isDark ? Colors.white : const Color(0xFF094D22)), 
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false
                  );
                }
              }
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[500] : const Color(0xFF6B7280))),
                const SizedBox(height: 4),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                  builder: (context, snapshot) {
                    String name = "User";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      name = snapshot.data!.get('name') ?? "User";
                    }
                    return Text(
                      'Welcome, $name', 
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)
                      )
                    );
                  }
                ),
                const SizedBox(height: 20),
                
                // Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      icon: Icon(Icons.search, color: isDark ? Colors.grey[600] : const Color(0xFF8B7A7B)),
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[700] : const Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Filter Row
                SizedBox(
                  height: 45,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.tune, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 24, color: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('filters').snapshots(),
                          builder: (context, snapshot) {
                            List<String> filters = ['All'];
                            if (snapshot.hasData) {
                              for (var doc in snapshot.data!.docs) {
                                filters.add(doc['name']);
                              }
                            }
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filters.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final label = filters[index];
                                final isSelected = _selectedFilter == label;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedFilter = label),
                                  child: _buildFilterChip(label, isSelected, isDark),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Products Grid
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('No products available', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey))));
                    }

                    var docs = snapshot.data!.docs;

                    if (_selectedFilter != 'All') {
                      docs = docs.where((doc) => doc['category'] == _selectedFilter).toList();
                    }

                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) => 
                        (doc['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (docs.isEmpty) {
                      return Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Matching products not found', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey))));
                    }

                    return GridView.builder(
                      itemCount: docs.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final product = docs[index].data() as Map<String, dynamic>;
                        return _buildProductCard(
                          product,
                          product['title'] ?? 'No Name',
                          product['price'] ?? '₹0',
                          product['isAvailable'] ?? true,
                          isDark: isDark,
                          tag: product['tag'] as String?,
                          tagColorHex: product['tagColorHex'] as String?,
                          imageUrl: product['imageUrl'] ?? '',
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected 
          ? (isDark ? const Color(0xFF094D22).withOpacity(0.3) : const Color(0xFFE5F5E9)) 
          : (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: const Color(0xFF094D22), width: 1.5) : null,
      ),
      child: Center(
        child: Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            color: isSelected 
              ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) 
              : (isDark ? Colors.grey[500] : const Color(0xFF6B7280))
          )
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> productData, String title, String price, bool isAvailable, {required bool isDark, String? tag, String? tagColorHex, required String imageUrl}) {
    Color? tagColor = tagColorHex != null ? Color(int.parse(tagColorHex.replaceFirst('#', '0xff'))) : Colors.green;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _handleProductTap(productData),
                  child: Container(
                    decoration: BoxDecoration(color: isDark ? Colors.grey[900] : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.image, color: isDark ? Colors.grey[800] : Colors.grey)),
                      ),
                    ),
                  ),
                ),
                if (tag != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF1E1E1E)), maxLines: 1),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? const Color(0xFF81C784) : const Color(0xFF094D22))),
              if (productData['unitValue'] != null && productData['unitValue'].toString().isNotEmpty)
                Text(' / ${productData['unitValue']}${productData['unitType']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[600], fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: isAvailable ? Colors.green : Colors.red, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(isAvailable ? 'AVAILABLE' : 'UNAVAILABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isAvailable ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) : Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: isAvailable ? () => _handleProductTap(productData) : null,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: isAvailable ? (isDark ? const Color(0xFF094D22).withOpacity(0.3) : const Color(0xFF98F598)) : (isDark ? Colors.grey[900] : const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.shopping_cart, color: isAvailable ? (isDark ? const Color(0xFF81C784) : const Color(0xFF094D22)) : (isDark ? Colors.grey[700] : const Color(0xFF9CA3AF)), size: 18),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: isAvailable ? () => _handleProductTap(productData, isBuyNow: true) : null,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(color: isAvailable ? const Color(0xFF094D22) : (isDark ? Colors.grey[900] : const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(isAvailable ? 'Buy Now' : 'Notify', style: TextStyle(color: isAvailable ? Colors.white : (isDark ? Colors.grey[700] : const Color(0xFF9CA3AF)), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
