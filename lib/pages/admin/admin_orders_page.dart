import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.5),
                children: [
                  TextSpan(text: 'Managing current store activity for '),
                  TextSpan(
                    text: 'Bharathi\nStore',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Toggle
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Present Orders',
                        style: TextStyle(
                          color: Color(0xFF094D22),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: const Text(
                        'Past Orders',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Active Order
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF86EFAC).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'IN PREPARATION',
                      style: TextStyle(
                        color: Color(0xFF094D22),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ananya Sharma',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                      children: [
                        TextSpan(text: '42, Green Park Avenue • 12 Items • '),
                        TextSpan(
                          text: '₹4,250',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF094D22),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Complete Packing',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Details',
                            style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Inactive Orders
            _buildSmallOrderCard('Rohan K.', '15th Cross, Sector 4 • 3 items • ₹1,240', Icons.local_shipping),
            _buildSmallOrderCard('Suresh M.', 'Rose Garden, Block A • 1 item • ₹350', Icons.assignment),
            _buildSmallOrderCard('Leila G.', 'Windsor Court, Flat 202 • 8 items • ₹2,890', Icons.shopping_bag),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallOrderCard(String title, String detailsStr, IconData icon) {
    final parts = detailsStr.split(' • ');
    final lastPart = parts.isNotEmpty ? parts.last : '';
    final firstPart = parts.length > 1 ? detailsStr.substring(0, detailsStr.lastIndexOf(' • ') + 3) : detailsStr;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF094D22), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
                    children: [
                      TextSpan(text: parts.length > 1 ? firstPart : detailsStr),
                      if (parts.length > 1)
                        TextSpan(
                          text: lastPart,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
