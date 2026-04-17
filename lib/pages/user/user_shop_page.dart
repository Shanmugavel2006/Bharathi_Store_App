import 'package:flutter/material.dart';
import 'user_checkout_page.dart';

class UserShopPage extends StatelessWidget {
  const UserShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF094D22)),
            onPressed: () {},
          ),
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
            IconButton(icon: const Icon(Icons.search, color: Color(0xFF094D22)), onPressed: () {}),
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildProductCard(
                      'Fresh Broccoli', '₹45.00', true, 
                      tag: 'ORGANIC', tagColor: const Color(0xFF558B2F),
                      imageColor: Colors.black87,
                    ),
                    _buildProductCard(
                      'Farm Fresh Milk', '₹68.00', false,
                      imageColor: Colors.teal.shade300,
                    ),
                    _buildProductCard(
                      'Red Gala Apples', '₹180.00', true,
                      tag: 'BEST', tagColor: const Color(0xFF558B2F),
                      imageColor: Colors.black,
                    ),
                    _buildProductCard(
                      'Handmade Cookies', '₹120.00', true,
                      imageColor: Colors.black,
                    ),
                  ],
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

  Widget _buildProductCard(String title, String price, bool isAvailable, {String? tag, Color? tagColor, required Color imageColor}) {
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
                    color: imageColor,
                    borderRadius: BorderRadius.circular(16),
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
