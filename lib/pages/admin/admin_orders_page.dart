import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatefulWidget {
  final bool isStandalone;
  const AdminOrdersPage({super.key, this.isStandalone = false});

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

    // Fetch all orders and sort/filter in-memory for maximum reliability
    final stream = FirebaseFirestore.instance.collection('orders').snapshots();

    Widget content = Padding(
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
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allDocs = snapshot.hasData ? snapshot.data!.docs : [];
                
                // Sort by createdAt descending
                allDocs.sort((a, b) {
                  final aTime = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  final bTime = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return bTime.compareTo(aTime);
                });

                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = (data['status'] ?? '').toString().toUpperCase();
                  if (_showPresentOrders) {
                    // Include 'IN PREPARATION', 'CONFIRMED', 'PENDING', or empty status in Present Orders
                    return status == 'IN PREPARATION' || status == 'CONFIRMED' || status == 'PENDING' || status == '';
                  } else {
                    // Include 'DELIVERED', 'COMPLETED', 'CANCELLED' in Past Orders
                    return status == 'DELIVERED' || status == 'COMPLETED' || status == 'CANCELLED';
                  }
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _showPresentOrders ? 'No active orders' : 'No past orders found',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final order = filteredDocs[index].data() as Map<String, dynamic>;
                    final docId = filteredDocs[index].id;
                    return _buildOrderCard(docId, order);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Store Orders', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
        ),
        body: content,
      );
    }
    return content;
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
              if (status == 'IN PREPARATION')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'CONFIRMED'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Confirm Order',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else if (status == 'CONFIRMED')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': 'DELIVERED'});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF094D22),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Mark as Delivered',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Delivered',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => _showOrderDetailsDialog(context, docId, order),
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

  void _showOrderDetailsDialog(BuildContext context, String orderId, Map<String, dynamic> order) {
    final items = (order['items'] as List? ?? []);
    final customerName = order['customerName'] ?? 'Guest';
    final phone = order['phone'] ?? 'No phone';
    final address = order['address'] ?? 'No address';
    final total = order['totalAmount'] ?? '₹0';
    final status = order['status'] ?? 'PENDING';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            Text('ID: #$orderId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Section
                const Text('CUSTOMER INFO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                const SizedBox(height: 8),
                Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Phone: $phone', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text('Address: $address', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                
                // Items Section
                const Text('ORDERED ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                const SizedBox(height: 12),
                ...items.map((item) {
                  final data = item as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(data['imageUrl'] ?? '', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.shopping_bag)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['title'] ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Quantity: ${data['quantity']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text(data['price'] ?? '₹0', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
                
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                
                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF094D22))),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Status Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN PREPARATION': return const Color(0xFF094D22);
      case 'CONFIRMED': return Colors.blue;
      case 'DELIVERED': return const Color(0xFF094D22);
      case 'COMPLETED': return Colors.grey;
      case 'CANCELLED': return Colors.red;
      default: return const Color(0xFF094D22);
    }
  }
}
