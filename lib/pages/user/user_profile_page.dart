import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
            onPressed: () {},
          ),
          title: const Text('Profile', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.settings, color: Color(0xFF094D22)), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EFE9).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF374151),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 60),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFF094D22), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Ananth Bharathi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.email, size: 14, color: Color(0xFF4B5563)),
                            SizedBox(width: 8),
                            Text('ananth@bharathistore.com', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone, size: 14, color: Color(0xFF4B5563)),
                            SizedBox(width: 8),
                            Text('+91 98765 43210', style: TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Present Orders
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Present Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF86EFAC), borderRadius: BorderRadius.circular(12)),
                            child: const Text('1 ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Expanded(child: Text('Fresh Spinach, Organic Tomatoes, Alphonso Mangoes (2kg)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                SizedBox(width: 16),
                                Text('₹850.00', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF094D22))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('14 Oct, 10:30 AM', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(3)))),
                                Expanded(child: Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(3)))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Past Orders
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Past Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                          Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4B5563))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPastOrder('Whole Wheat Flour, Brown Rice, Cold Pressed Oil', '₹1,240.00', '12 Oct, 04:15 PM'),
                      const SizedBox(height: 12),
                      _buildPastOrder('Organic Honey, Herbal Tea pack', '₹450.00', '05 Oct, 11:20 AM'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Saved Addresses
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Saved Addresses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                          Text('Add New', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.home, color: Color(0xFF094D22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Home', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  SizedBox(height: 4),
                                  Text('No. 42, 3rd Cross, 1st Main Road,\nIndiranagar, Bengaluru - 560038', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Settings
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Icon(Icons.notifications, color: Color(0xFF4B5563)),
                          SizedBox(width: 16),
                          Expanded(child: Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                          Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Icon(Icons.logout, color: Color(0xFFD32F2F)),
                          SizedBox(width: 16),
                          Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFD32F2F))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPastOrder(String title, String price, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              const SizedBox(width: 16),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}
