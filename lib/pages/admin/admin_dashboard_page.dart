import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Store Statistics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF094D22),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF81C784),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildStatCard(
                  'Total Products', 
                  'products', 
                  Icons.inventory_2_outlined, 
                  const Color(0xFFE3F2FD), 
                  const Color(0xFF1976D2)
                ),
                _buildStatCard(
                  'Registered Users', 
                  'users', 
                  Icons.people_outline, 
                  const Color(0xFFF1F8E9), 
                  const Color(0xFF388E3C)
                ),
                _buildStatCard(
                  'Delivery Register', 
                  'delivery_partners', // Assuming this collection exists or will be used
                  Icons.local_shipping_outlined, 
                  const Color(0xFFFFF3E0), 
                  const Color(0xFFF57C00)
                ),
                _buildStatCard(
                  'Pending Orders', 
                  'orders', 
                  Icons.pending_actions_outlined, 
                  const Color(0xFFFCE4EC), 
                  const Color(0xFFC2185B),
                  query: (ref) => ref.where('status', isEqualTo: 'pending')
                ),
                _buildStatCard(
                  'Completed Orders', 
                  'orders', 
                  Icons.check_circle_outline, 
                  const Color(0xFFE8F5E9), 
                  const Color(0xFF2E7D32),
                  query: (ref) => ref.where('status', isEqualTo: 'completed')
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 16),
            
            // Activity placeholder or simple list
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
                children: [
                  _buildActivityRow('New order received from Ananya S.', '2 mins ago'),
                  const Divider(height: 32),
                  _buildActivityRow('Product "Organic Honey" updated', '1 hour ago'),
                  const Divider(height: 32),
                  _buildActivityRow('New user "Saran" registered', '3 hours ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String collection, IconData icon, Color bgColor, Color iconColor, {Query Function(CollectionReference)? query}) {
    Query baseQuery = FirebaseFirestore.instance.collection(collection);
    if (query != null) {
      baseQuery = query(FirebaseFirestore.instance.collection(collection));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: baseQuery.snapshots(),
      builder: (context, snapshot) {
        String count = '...';
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length.toString();
        } else if (snapshot.hasError) {
          count = '0';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActivityRow(String title, String time) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF094D22),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
