import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import 'user_checkout_page.dart';

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

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      // Check if item already exists
      final existing = await cartRef.where('title', isEqualTo: product['title']).get();
      
      if (existing.docs.isNotEmpty) {
        // Increment quantity
        await cartRef.doc(existing.docs.first.id).update({
          'quantity': FieldValue.increment(1),
        });
      } else {
        // Add new item
        await cartRef.add({
          'title': product['title'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
          'tag': product['tag'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['title']} added to cart'),
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

  void _buyNow(Map<String, dynamic> product) async {
    // For Buy Now, we can either clear cart and add this, or just pass it to checkout
    // Let's just add to cart and navigate to checkout
    await _addToCart(product);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserCheckoutPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          title: Row(
            children: [
              // REQUIREMENT 1: Logo before shop name
              Image.asset(
                'assets/images/logo.png',
                height: 45,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.store, color: Color(0xFF094D22), size: 40),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bharathi',
                    style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Departmental Store',
                    style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF094D22)), 
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCheckoutPage()));
              }
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF094D22)), 
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
                // REQUIREMENT 2: Time based greeting
                Text(_getGreeting(), style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                  builder: (context, snapshot) {
                    String name = "User";
                    if (snapshot.hasData && snapshot.data!.exists) {
                      name = snapshot.data!.get('name') ?? "User";
                    }
                    return Text('Welcome, $name', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF094D22)));
                  }
                ),
                const SizedBox(height: 20),
                
                // Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Color(0xFF8B7A7B)),
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // REQUIREMENT 3: Filter container managed by Admin
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
                            SizedBox(width: 8),
                            Text('Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
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
                                  child: _buildFilterChip(label, isSelected),
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
                
                // REQUIREMENT 4/LOGIC: Fetch live products from Firebase
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No products available')));
                    }

                    var docs = snapshot.data!.docs;

                    // Filter Logic: Category
                    if (_selectedFilter != 'All') {
                      docs = docs.where((doc) => doc['category'] == _selectedFilter).toList();
                    }

                    // Filter Logic: Search
                    if (_searchQuery.isNotEmpty) {
                      docs = docs.where((doc) => 
                        (doc['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                    }

                    if (docs.isEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Matching products not found')));
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE5F5E9) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: const Color(0xFF094D22), width: 1.5) : null,
      ),
      child: Center(
        child: Text(
          label, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 13,
            color: isSelected ? const Color(0xFF094D22) : const Color(0xFF6B7280)
          )
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> productData, String title, String price, bool isAvailable, {String? tag, String? tagColorHex, required String imageUrl}) {
    Color? tagColor = tagColorHex != null ? Color(int.parse(tagColorHex.replaceFirst('#', '0xff'))) : Colors.green;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, color: Colors.grey)),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)), maxLines: 1),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF094D22))),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: isAvailable ? Colors.green : Colors.red, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(isAvailable ? 'AVAILABLE' : 'UNAVAILABLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF094D22) : Colors.red)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: isAvailable ? () => _addToCart(productData) : null,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: isAvailable ? const Color(0xFF98F598) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.shopping_cart, color: isAvailable ? const Color(0xFF094D22) : const Color(0xFF9CA3AF), size: 18),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: isAvailable ? () => _buyNow(productData) : null,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(color: isAvailable ? const Color(0xFF094D22) : const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: Text(isAvailable ? 'Buy Now' : 'Notify', style: TextStyle(color: isAvailable ? Colors.white : const Color(0xFF9CA3AF), fontWeight: FontWeight.bold, fontSize: 12)),
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
