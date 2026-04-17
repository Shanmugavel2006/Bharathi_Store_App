import 'package:flutter/material.dart';
import 'user_order_success_page.dart';

class UserCheckoutPage extends StatefulWidget {
  const UserCheckoutPage({super.key});

  @override
  State<UserCheckoutPage> createState() => _UserCheckoutPageState();
}

class _UserCheckoutPageState extends State<UserCheckoutPage> {
  int _selectedPaymentMethod = 0;

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
        title: const Text('Checkout', style: TextStyle(color: Color(0xFF1E1E1E), fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Color(0xFF4B5563))),
                      SizedBox(height: 4),
                      Text('Your Selection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF98F598), borderRadius: BorderRadius.circular(12)),
                    child: const Text('2 ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF094D22))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildCartItem('Fresh Broccoli', '500g • Organic', '₹85', 'FRESH ARRIVAL', Colors.black87),
              const SizedBox(height: 12),
              _buildCartItem('Farm Fresh Milk', '1 Litre • Whole Milk', '₹65', 'PREMIUM', Colors.teal.shade300),
              
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
                      children: const [
                        Text('Subtotal', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                        Text('₹150', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Delivery Fee', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                        Text('Free', style: TextStyle(color: Color(0xFF094D22), fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: const Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Total Amount', style: TextStyle(color: Color(0xFF1E1E1E), fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹150', style: TextStyle(color: Color(0xFF094D22), fontSize: 24, fontWeight: FontWeight.bold)),
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
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserOrderSuccessPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF094D22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Row(
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
      ),
    );
  }

  Widget _buildCartItem(String title, String subtitle, String price, String tag, Color imageColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(color: imageColor, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E1E1E))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE5F5E9), borderRadius: BorderRadius.circular(8)),
                    child: Text(tag, style: const TextStyle(color: Color(0xFF558B2F), fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
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
