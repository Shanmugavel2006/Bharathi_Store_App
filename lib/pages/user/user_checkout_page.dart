import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_order_success_page.dart';

class UserCheckoutPage extends StatefulWidget {
  const UserCheckoutPage({super.key});

  @override
  State<UserCheckoutPage> createState() => _UserCheckoutPageState();
}

class _UserCheckoutPageState extends State<UserCheckoutPage> {
  int _selectedPaymentMethod = 0;
  final user = FirebaseAuth.instance.currentUser;
  bool _isPlacingOrder = false;

  double _parsePrice(String price) {
    return double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  Future<void> _placeOrder(List<QueryDocumentSnapshot> cartItems, double total) async {
    if (user == null) return;
    
    setState(() => _isPlacingOrder = true);

    try {
      // 1. Get user details
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // 2. Create order document
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user!.uid,
        'customerName': userData['name'] ?? 'Guest User',
        'address': userData['address'] ?? 'No Address Provided',
        'itemsCount': cartItems.length,
        'totalAmount': '₹${total.toStringAsFixed(2)}',
        'status': 'IN PREPARATION',
        'createdAt': FieldValue.serverTimestamp(),
        'paymentMethod': _getPaymentMethodName(),
      });

      // 3. Clear cart
      final cartBatch = FirebaseFirestore.instance.batch();
      for (var doc in cartItems) {
        cartBatch.delete(doc.reference);
      }
      await cartBatch.commit();

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserOrderSuccessPage()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error placing order: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 0: return 'Credit/Debit Card';
      case 1: return 'UPI';
      case 2: return 'Cash on Delivery';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text('Login required')));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF094D22)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Checkout', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          final cartItems = snapshot.data!.docs;
          double subtotal = 0;
          for (var item in cartItems) {
            final data = item.data() as Map<String, dynamic>;
            subtotal += _parsePrice(data['price'] ?? '0') * (data['quantity'] ?? 1);
          }
          double deliveryFee = subtotal > 500 ? 0 : 40;
          double total = subtotal + deliveryFee;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                          SizedBox(height: 4),
                          Text('Your Selection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFF98F598), borderRadius: BorderRadius.circular(12)),
                        child: Text('${cartItems.length} ITEMS', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = cartItems[index].data() as Map<String, dynamic>;
                      return _buildCartItem(
                        data['title'] ?? 'Product',
                        '${data['quantity']} x ${data['price']}',
                        '₹${(_parsePrice(data['price'] ?? '0') * (data['quantity'] ?? 1)).toStringAsFixed(0)}',
                        data['imageUrl'] ?? '',
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                            Text('₹${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Fee', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                            Text(deliveryFee == 0 ? 'Free' : '₹${deliveryFee.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF094D22), fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: const Color(0xFFE5E7EB)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF094D22), fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('Payment Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                  const SizedBox(height: 16),
                  
                  _buildPaymentOption(0, Icons.credit_card, 'Credit/Debit Card', 'Visa, Mastercard, RuPay'),
                  const SizedBox(height: 12),
                  _buildPaymentOption(1, Icons.account_balance_wallet, 'UPI (Google Pay/PhonePe)', 'Instant bank transfer'),
                  const SizedBox(height: 12),
                  _buildPaymentOption(2, Icons.money, 'Cash on Delivery', 'Pay when you receive'),
                  
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isPlacingOrder ? null : () => _placeOrder(cartItems, total),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF094D22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: _isPlacingOrder 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Place Order & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ],
                        ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(String title, String subtitle, String price, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () {
        setState(() { _selectedPaymentMethod = index; });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF094D22), width: 1.5) : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF094D22)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF094D22) : const Color(0xFFD1D5DB), width: isSelected ? 6 : 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
