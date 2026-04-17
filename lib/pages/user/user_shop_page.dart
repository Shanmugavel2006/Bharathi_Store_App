import 'package:flutter/material.dart';
import 'user_checkout_page.dart';

class UserShopPage extends StatefulWidget {
  const UserShopPage({super.key});

  @override
  State<UserShopPage> createState() => _UserShopPageState();
}

class _UserShopPageState extends State<UserShopPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allProducts = [
    {
      'title': 'Fresh Broccoli',
      'price': '₹45.00',
      'isAvailable': true,
      'tag': 'ORGANIC',
      'tagColor': const Color(0xFF558B2F),
      'imageUrl': 'https://images.unsplash.com/photo-1518843875459-f738682238a6?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Farm Fresh Milk',
      'price': '₹68.00',
      'isAvailable': false,
      'tag': null,
      'tagColor': null,
      'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Red Gala Apples',
      'price': '₹180.00',
      'isAvailable': true,
      'tag': 'BEST',
      'tagColor': const Color(0xFF558B2F),
      'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6faa6?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Handmade Cookies',
      'price': '₹120.00',
      'isAvailable': true,
      'tag': null,
      'tagColor': null,
      'imageUrl': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=400&q=80',
    },
  ];

  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) => product['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bharathi',
                style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Departmental Store',
                style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_bag, color: Color(0xFF094D22)), 
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCheckoutPage()));
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
                const Text('Good Morning,', style: TextStyle(fontSize: 16, color: Color(0xFF4B5563))),
                const SizedBox(height: 4),
                const Text('Welcome, Arjun', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                const SizedBox(height: 20),
                
                // Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterProducts,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, color: Color(0xFF8B7A7B)),
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.tune, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text('Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
                      const SizedBox(width: 12),
                      _buildFilterChip('Vegetables'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Fruits'),
                      const SizedBox(width: 12),
                      _buildFilterChip('Dairy'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Grid
                if (_filteredProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No products found', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                    ),
                  )
                else
                  GridView.builder(
                    itemCount: _filteredProducts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _buildProductCard(
                        product['title'],
                        product['price'],
                        product['isAvailable'],
                        tag: product['tag'],
                        tagColor: product['tagColor'],
                        imageUrl: product['imageUrl'],
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

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E))),
    );
  }

  Widget _buildProductCard(String title, String price, bool isAvailable, {String? tag, Color? tagColor, required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                if (tag != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(8)),
                      child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF094D22))),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(width: 4, height: 4, decoration: BoxDecoration(color: isAvailable ? const Color(0xFF4CAF50) : const Color(0xFFD32F2F), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(isAvailable ? 'AVAILABLE' : 'UNAVAILABLE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isAvailable ? const Color(0xFF094D22) : const Color(0xFFD32F2F))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAvailable ? const Color(0xFF98F598) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.shopping_cart, color: isAvailable ? const Color(0xFF094D22) : const Color(0xFF6B7280), size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isAvailable ? const Color(0xFF094D22) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isAvailable ? 'Buy Now' : 'Notify',
                    style: TextStyle(
                      color: isAvailable ? Colors.white : const Color(0xFF6B7280),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
