import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  bool _showPresentOrders = true;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    DateTime startOfLastMonth = now.subtract(const Duration(days: 30));

    Query query = FirebaseFirestore.instance.collection('orders');
    if (_showPresentOrders) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: startOfToday);
    } else {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: startOfLastMonth)
          .where('createdAt', isLessThan: startOfToday);
    }

    return Padding(
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
                  child: GestureDetector(
                    onTap: () => setState(() => _showPresentOrders = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _showPresentOrders ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _showPresentOrders 
                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Present Orders',
                        style: TextStyle(
                          color: _showPresentOrders ? const Color(0xFF094D22) : const Color(0xFF6B7280),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showPresentOrders = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_showPresentOrders ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_showPresentOrders 
                          ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                          : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Past Orders',
                        style: TextStyle(
                          color: !_showPresentOrders ? const Color(0xFF094D22) : const Color(0xFF6B7280),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _showPresentOrders ? 'No orders today' : 'No past orders found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final order = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    final docId = snapshot.data!.docs[index].id;
                    return _buildOrderCard(docId, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String docId, Map<String, dynamic> order) {
    String status = order['status'] ?? 'PENDING';
    String customerName = order['customerName'] ?? 'Unknown Customer';
    String address = order['address'] ?? 'No address provided';
    int itemsCount = order['itemsCount'] ?? 0;
    String totalAmount = order['totalAmount'] ?? '₹0';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                'ID: #${docId.substring(0, 6)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            customerName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
              children: [
                TextSpan(text: '$address • $itemsCount Items • '),
                TextSpan(
                  text: totalAmount,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: status == 'COMPLETED' ? null : () {
                    FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'COMPLETED'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094D22),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    status == 'COMPLETED' ? 'Completed' : 'Complete Packing',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  // Show Details logic here
                },
                child: const Text(
                  'Details',
                  style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN PREPARATION': return const Color(0xFF094D22);
      case 'SHIPPED': return Colors.blue;
      case 'COMPLETED': return Colors.grey;
      case 'CANCELLED': return Colors.red;
      default: return const Color(0xFF094D22);
    }
  }
}
