import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserOrderDetailsPage extends StatefulWidget {
  final String orderId;
  const UserOrderDetailsPage({super.key, required this.orderId});

  @override
  State<UserOrderDetailsPage> createState() => _UserOrderDetailsPageState();
}

class _UserOrderDetailsPageState extends State<UserOrderDetailsPage> {
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showEditAddressDialog(String currentAddress) {
    _addressController.text = currentAddress;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Delivery Address'),
        content: TextField(
          controller: _addressController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter new address',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_addressController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(widget.orderId)
                    .update({'address': _addressController.text.trim()});
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF094D22)),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Details', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final status = orderData['status'] ?? 'PENDING';
          final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final formattedDate = DateFormat('MMMM dd, yyyy • hh:mm a').format(createdAt);
          final items = (orderData['items'] as List<dynamic>?) ?? [];
          final canEditAddress = status == 'IN PREPARATION';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Status Card
                  Container(
                    width: double.infinity,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Order Placed on $formattedDate',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text('#${widget.orderId.substring(0, 8)}', style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildStatusStep('Ordered', true),
                            _buildStatusLine(status == 'CONFIRMED' || status == 'DELIVERED' || status == 'COMPLETED'),
                            _buildStatusStep('Confirmed', status == 'CONFIRMED' || status == 'DELIVERED' || status == 'COMPLETED'),
                            _buildStatusLine(status == 'DELIVERED' || status == 'COMPLETED'),
                            _buildStatusStep('Delivered', status == 'DELIVERED' || status == 'COMPLETED'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Address
                  const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(orderData['customerName'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (canEditAddress)
                              TextButton.icon(
                                onPressed: () => _showEditAddressDialog(orderData['address'] ?? ''),
                                icon: const Icon(Icons.edit, size: 16, color: Color(0xFF094D22)),
                                label: const Text('Change', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(orderData['phone'] ?? '', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 12),
                        Text(orderData['address'] ?? 'No address', style: const TextStyle(color: Color(0xFF4B5563), height: 1.5)),
                        if (!canEditAddress)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              'Address cannot be changed after order confirmation.',
                              style: TextStyle(color: Colors.red, fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Items List
                  const Text('ITEMS ORDERED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['imageUrl'] ?? '', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('${item['quantity']} x ${item['price']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(
                              '₹${(double.tryParse((item['price'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0 * (item['quantity'] ?? 1)).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Payment Summary
                  const Text('PAYMENT SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text(orderData['totalAmount'] ?? '₹0', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Method', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text(orderData['paymentMethod'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN PREPARATION': return const Color(0xFF094D22);
      case 'CONFIRMED': return Colors.blue;
      case 'COMPLETED': return Colors.grey;
      case 'DELIVERED': return const Color(0xFF094D22);
      case 'CANCELLED': return Colors.red;
      default: return const Color(0xFF094D22);
    }
  }

  Widget _buildStatusStep(String label, bool isTicked) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isTicked ? const Color(0xFF094D22) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isTicked ? const Color(0xFF094D22) : Colors.grey[300]!, width: 2),
            ),
            child: isTicked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isTicked ? FontWeight.bold : FontWeight.normal, color: isTicked ? const Color(0xFF094D22) : Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildStatusLine(bool isFinished) {
    return Container(
      width: 40, height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isFinished ? const Color(0xFF094D22) : Colors.grey[200],
    );
  }
}
