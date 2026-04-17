import 'package:flutter/material.dart';

class AdminManageItemsPage extends StatelessWidget {
  const AdminManageItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Control',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Audit and update your product availability.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products, categories, SKU...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFEBEBEB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Items List
                _buildItemCard(
                  category: 'ORGANIC',
                  sku: '#SKU-9021',
                  title: 'Sustainably Sourced Kale',
                  price: '\$4.50',
                  isAvailable: true,
                  imageColor: Colors.green.shade900,
                  icon: Icons.grass,
                ),
                _buildItemCard(
                  category: 'STANDARD',
                  sku: '#SKU-4412',
                  title: 'Bunch of Garden Carrots',
                  price: '\$2.99',
                  isAvailable: true,
                  imageColor: Colors.orange.shade800,
                  icon: Icons.shopping_basket,
                ),
                _buildItemCard(
                  category: 'KITCHEN',
                  sku: '#SKU-0012',
                  title: 'Artisan Greek Salad',
                  price: '\$12.00',
                  isAvailable: false,
                  imageColor: Colors.brown.shade400,
                  icon: Icons.fastfood,
                  outOfStock: true,
                ),
                _buildItemCard(
                  category: 'BERRY FARM',
                  sku: '#SKU-2921',
                  title: 'Native Strawberries',
                  price: '\$6.25',
                  isAvailable: true,
                  imageColor: Colors.red.shade900,
                  icon: Icons.eco,
                ),
                _buildItemCard(
                  category: 'CITRUS',
                  sku: '#SKU-7701',
                  title: 'Zesty Lemon Pack (6pc)',
                  price: '\$3.49',
                  isAvailable: true,
                  imageColor: Colors.yellow.shade800,
                  icon: Icons.wb_sunny,
                ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF094D22),
            onPressed: () {},
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required String category,
    required String sku,
    required String title,
    required String price,
    required bool isAvailable,
    required Color imageColor,
    required IconData icon,
    bool outOfStock = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: imageColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 40),
              ),
              if (outOfStock)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'OUT OF\nSTOCK',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: outOfStock ? const Color(0xFF869287) : const Color(0xFF558B2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      sku,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF094D22),
                      ),
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.75,
                          child: Switch(
                            value: isAvailable,
                            onChanged: (val) {},
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF094D22),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFE5E7EB),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: isAvailable ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
