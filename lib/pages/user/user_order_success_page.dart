import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'user_order_details_page.dart';

class UserOrderSuccessPage extends StatelessWidget {
  final String orderId;
  const UserOrderSuccessPage({super.key, required this.orderId});

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
        title: const Text('Bharathi Store', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final createdAt = (orderData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
          final formattedDate = DateFormat('MMMM dd, yyyy').format(createdAt);
          final formattedTime = DateFormat('hh:mm a').format(createdAt);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(color: const Color(0xFF98F598), borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.check_circle, color: Color(0xFF094D22), size: 48),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Order Placed\nSuccessfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF094D22)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thank you for choosing Bharathi Departmental Store.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 40),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ORDER DETAILS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                const SizedBox(height: 4),
                                Text(formattedDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Time', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                const SizedBox(height: 4),
                                Text(formattedTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DELIVERY ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                        const SizedBox(height: 16),
                        Text(orderData['customerName'] ?? 'Guest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                        const SizedBox(height: 4),
                        Text(orderData['phone'] ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                        const SizedBox(height: 16),
                        Text(orderData['address'] ?? 'No address', style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: const Color(0xFF094D22), borderRadius: BorderRadius.circular(16)),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          bottom: -30,
                          child: Icon(Icons.eco, color: Colors.white.withOpacity(0.08), size: 150),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ORDER SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF86EFAC))),
                              const SizedBox(height: 16),
                              const Text('Total Amount Paid', style: TextStyle(fontSize: 11, color: Color(0xFF86EFAC))),
                              const SizedBox(height: 4),
                              Text(orderData['totalAmount'] ?? '₹0.00', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFF1B5E20), borderRadius: BorderRadius.circular(12)),
                                child: Text('PAID VIA ${(orderData['paymentMethod'] ?? 'Unknown').toUpperCase()}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => UserOrderDetailsPage(orderId: orderId)));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF094D22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('View Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Back to Home', style: TextStyle(color: Color(0xFF094D22), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

